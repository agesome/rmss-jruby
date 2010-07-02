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
    # @shell.setBounds(Display.getDefault().getPrimaryMonitor().getBounds());

    @shell.setSize(500, 500)
    
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
    # @Data = Label.new(@shell, SWT::NONE);
    Thread.new do
      while true
        @display.asyncExec do
          begin
            @dev.parse_data
          rescue EOFError
            puts "disconnect, exiting!"
            exit
          end
          # puts 't' + @dev.temperature.last.to_s
          # puts 'h' + @dev.humidity.last.to_s
          # puts 'a' + @dev.acceleration.last.inspect
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
          # @Data.setText("Temperture: #{@dev.temperature.last.to_s}\nHumidity: #{@dev.humidity.last.to_s}\nAcceleration: #{@dev.acceleration.last.inspect}")
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
