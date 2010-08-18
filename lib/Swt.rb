require 'rbconfig'
require 'java'
include Config

if CONFIG["host_cpu"] =~ /x86_64|amd64/
  path = 'jar64/swt'
else
  path = 'jar/swt'
end

puts path
require path

module Swt
  import org.eclipse.swt.SWT;
  import org.eclipse.swt.graphics.Point;
  import org.eclipse.swt.graphics.Rectangle;
  import org.eclipse.swt.widgets.Display;
  import org.eclipse.swt.widgets.Shell;
  import org.eclipse.swt.layout.RowLayout;
  import org.eclipse.swt.layout.FillLayout;
  import org.eclipse.swt.layout.GridLayout;
  import org.eclipse.swt.widgets.Label;
  import org.eclipse.swt.widgets.Button;
  import org.eclipse.swt.events.SelectionEvent;
  import org.eclipse.swt.events.SelectionListener;
  import org.eclipse.swt.widgets.Canvas;
  import org.eclipse.swt.widgets.Composite;
  import org.eclipse.swt.custom.ViewForm; 
end
