var $stackedChart = undefined;
$(function () {
    $stackedChart = new Highcharts.Chart({
        chart: {
           renderTo:'stacked-container'  ,
           type: 'column',
           zoomType: 'xy'
       },
        title: {
            text: stackedTitleName
        },
        xAxis: {
            labels: {
                rotation: -45,
                align: 'right',
                style: {
                    fontSize: '13px',
                    fontFamily: 'Verdana, sans-serif'
                }
            },
            categories: categoryData
        },
        yAxis: {
            min: 0,
            title: {
                text: yAxisTitleName
            },
            stackLabels: {
                enabled: true,
                formatter: function(){
                    if(this.y=='0') return this.y='';
                    else return this.y;
                },
                style: {
                    fontWeight: 'bold',
                    color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
                }
            }
        },
        legend: {
            align: 'right',
            x: -100,
            verticalAlign: 'top',
            y: 20,
            floating: true,
            backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColorSolid) || 'white',
            borderColor: '#CCC',
            borderWidth: 1,
            shadow: false
        },
        tooltip: {
            formatter: function() {
                return '<b>'+ this.x +'</b><br/>'+
                    this.series.name +': '+ this.y +'<br/>'+
                    'Total: '+ this.point.stackTotal;
            }
        },
        plotOptions: {
            column: {
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    formatter: function(){
                          if (this.y > 0)
                              return this.y
                          else
                              return this.y='';
                    },
                    color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                },
                point:{
                    events:{
                        click:function(){
                            console.log(this.series.name);
                            console.log(this.category);
                            var projectId = $('input[name="projectId"]').val();
                            var url ="/generate-report?selected_date='"+this.category+"'&status_id="+this.series.name+"&project_id="+projectId;
                            console.log(url);
                            window.open(url,'_blank');
                        }
                    }
                }
            }
        },
        series: seriesData
    });
});