require 'Swt'
require 'Graph'
require 'Draw2D'
require 'Device'

class MainGUI
  include Swt
  include Draw2D
  WINDOW_NAME = 'jrmss'
  
  def initialize
    @display = Display.getDefault
    @shell = Shell.new(@display)
    @shell.layout = FillLayout.new(SWT::NONE)
    @shell.text = WINDOW_NAME
    @shell.setBounds(Display.getDefault().getPrimaryMonitor().getBounds());

    @dev = Device.new
    begin
      @dev.connect
    rescue EOFError => why
      puts "couldn't connect, exiting (#{why.to_s})"
      exit
    end
    @HData = []
    @HDgraph = Graph.new(@shell, "humidity", "time", "value")
    @TData = []
    @TGraph = Graph.new(@shell, "temperature", "time", "value")
    @AXData = []
    @AYData = []
    @AZData = []
    @AXGraph = Graph.new(@shell, "acceleration", "time", "value")
    @AYGraph = Graph.new(@shell, "", "time", "value")
    @AZGraph = Graph.new(@shell, "", "time", "value")
    Thread.new do
      while true
        @display.asyncExec do
          begin
            @dev.parse_data
          rescue EOFError
            puts "disconnect, exiting!"
            exit
          end
          # puts @dev.temperature.last.to_i.to_s
          @HData << @dev.humidity.last
          @HDgraph.addSeries(@HData, "fi")
          @TData << @dev.temperature.last.to_i
          @TGraph.addSeries(@TData, "c")
          @dev.acceleration[-4..-1].each do |value|
            @AXData << value[0].to_i
          end
          @AXGraph.addSeries(@AXData, "x")
          @dev.acceleration[-4..-1].each do |value|
            @AYData << value[1].to_i
          end
          @AYGraph.addSeries(@AYData, "y")
          @dev.acceleration[-4..-1].each do |value|
            @AZData << value[2].to_i
          end
          @AZGraph.addSeries(@AZData, "z")
         end
        Kernel::sleep(1)
      end
    end

    @shell.open
    while !@shell.isDisposed do
      @display.sleep unless @display.readAndDispatch
    end
  end
end
