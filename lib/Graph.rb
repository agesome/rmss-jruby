require 'java'
require 'Draw2D'
require 'Swt'
require 'jar/jfreechart'
require 'jar/jfreechart-swt'
require 'jar/jcommon'

class Graph
  import org.jfree.chart.ChartFactory;
  import org.jfree.chart.JFreeChart;
  import org.jfree.chart.plot.CategoryPlot;
  import org.jfree.chart.plot.PlotOrientation;
  import org.jfree.data.xy.XYDataset;
  import org.jfree.data.xy.XYSeries;
  import org.jfree.data.xy.XYSeriesCollection;
  import org.jfree.experimental.chart.swt.ChartComposite;
  import org.jfree.chart.ChartUtilities;
  import java.awt.Color;
  include Draw2D
  include Swt
  
  def initialize(parent, name, xname, yname)
    @dataset = XYSeriesCollection.new
    @chart = ChartFactory::createXYLineChart(name, xname, yname,
                                             @dataset,
                                             PlotOrientation::VERTICAL,
                                             true,
                                             false,
                                             false)
    plot = @chart.getPlot
    plot.setBackgroundPaint(Color.white);
    plot.setDomainGridlinePaint(Color.gray);
    plot.setDomainGridlinesVisible(true);
    plot.setRangeGridlinePaint(Color.white);
    @composite = ChartComposite.new(parent, SWT::NONE,
                                    @chart, true)
    @series = {}
  end

  def addSeries(array, name)
    if not @series[name]
      series = XYSeries.new(name)
      @series[name] = series
      @dataset.addSeries(series)
    else
      series = @series[name]
    end
    array.each do |value|
      series.add(array.index(value), value)
    end
  end
end
