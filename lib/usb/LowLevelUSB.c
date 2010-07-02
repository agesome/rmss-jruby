/*
  This file is part of rmss.
  
  rmss is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  rmss is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with rmss.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <libusb.h>
#include "LowLevelUSB.h"

#define USB_VID 0x16C0
#define USB_PID 0x05DC
#define USB_PNAME "MSS"

libusb_context *ctx;
libusb_device_handle *dh;
unsigned char data_buffer[64];

char *
usb_decode_error (int code)
{
  switch (code)
    {
    case LIBUSB_ERROR_IO:
      return "input/output error";
    case LIBUSB_ERROR_INVALID_PARAM:
      return "invalid parameter";
    case LIBUSB_ERROR_ACCESS:
      return "access denied";
    case LIBUSB_ERROR_NO_DEVICE:
      return "no such device";
    case LIBUSB_ERROR_NOT_FOUND:
      return "entity not found";
    case LIBUSB_ERROR_BUSY:
      return "resource busy";
    case LIBUSB_ERROR_TIMEOUT:
      return "operation timed out";
    case LIBUSB_ERROR_OVERFLOW:
      return "overflow";
    case LIBUSB_ERROR_PIPE:
      return "pipe error";
    case LIBUSB_ERROR_INTERRUPTED:
      return "system call interrupted";
    case LIBUSB_ERROR_NO_MEM:
      return "insufficient memory";
    case LIBUSB_ERROR_NOT_SUPPORTED:
      return "operation not supported";
    case LIBUSB_ERROR_OTHER:
      return "unknown error";
    case 0:
    default:
      return NULL;
    }
}

int
usb_init (int dlevel)
{
  int rc;

  rc = libusb_init (&ctx);
  if (rc)
    {
      fprintf (stderr, usb_decode_error (rc));
      return 1;
    }

  if (dlevel >= 0 && dlevel <= 3)
    {
      libusb_set_debug (ctx, dlevel);
    }
  else
    {
      fprintf (stderr,
	     "Warning: Tried to set abnormal debug level. Ingoring.\n");
    }
  return 0;
}

char *
usb_open_dev (void)
{
  struct libusb_device_descriptor desc;
  /* there should be a way to know product name string lenght, but this is okay for now */
  char product_name[64];
  int rc = 0;
  char *msg;
  
  dh = libusb_open_device_with_vid_pid (ctx, USB_VID, USB_PID);
  if (dh == NULL)
    {
      return "'libusb_open_device_with_vid_pid' failed";
    }
  rc = libusb_get_device_descriptor (libusb_get_device (dh), &desc);
  msg = usb_decode_error (rc);
  if (msg != NULL)
    {
      /* printf ("devdesc\n"); */
      return msg;
    }
  rc = libusb_get_string_descriptor_ascii (dh, desc.iProduct, (unsigned char *) product_name, 64);
  msg = usb_decode_error (rc);
  if (msg != NULL)
    {
      /* printf ("desc\n"); */
      return msg;
    }
  if (strcmp (product_name, USB_PNAME) != 0)
    {
      return "wrong device found";
    }
  return NULL;
}


JNIEXPORT void JNICALL Java_LowLevelUSB_close
(JNIEnv * env, jobject obj)
{
  libusb_close (dh);
  libusb_exit (ctx);
}

JNIEXPORT jobjectArray JNICALL Java_LowLevelUSB_fetchData
(JNIEnv *env, jobject obj)
{
  int rc = libusb_control_transfer (dh,
				    LIBUSB_REQUEST_TYPE_VENDOR |
				    LIBUSB_RECIPIENT_DEVICE | LIBUSB_ENDPOINT_IN,
				    0, 0, 0, data_buffer, 64,
				    500);
  char *errMsg = usb_decode_error (rc);
  if (errMsg != NULL)
    {
      (*env)->ThrowNew (env, (*env)->FindClass (env, "java/io/IOException"),
			errMsg);
      /* do not remove! ThrowNew doesn't return from here */
      return;
    }
  /* printf ("bytes recv: %d\n", rc); */
  jbyteArray result = (*env)->NewByteArray (env, rc);
  (*env)->SetByteArrayRegion (env, result, 0, rc, data_buffer);
  return result;
}

JNIEXPORT void JNICALL Java_LowLevelUSB_initializeUSB
(JNIEnv *env, jobject obj, jint debug)
{
  int rc;
  char *msg;

  rc = usb_init (debug);
  if (rc)
    {
      (*env)->ThrowNew (env, (*env)->FindClass (env, "java/io/IOException"), "failed to initialize LibUSB");
      return;
    }
  msg = usb_open_dev ();
  if (msg != NULL)
    {
      (*env)->ThrowNew (env, (*env)->FindClass (env, "java/io/IOException"), msg);
      return;
    }
}
