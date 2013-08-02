var $pieChart = undefined;
$(function () {

    $pieChart = new Highcharts.Chart({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: true,
            renderTo : "pie-container",
            event : {
                click:function(e) {
                    //alert(e)
                    //alert('The name is ' + this.name +' and the identifier is ' + this.options.id);
                }
            }
        },
        title: {
            text: pieTitleName
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.y} ({point.percentage:.1f} %)</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    color: '#000000',
                    connectorColor: '#000000',
                    format: '<b>{point.name}</b>: {point.y} ({point.percentage:.1f} %)'
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Percentage',
            data: piaChartData,
            point:{
                events:{
                    click: function (event) {
                        var status = event.currentTarget.name;
                        var dateRangeParams = getDateRangeParams();
                        var projectId = $('input[name="projectId"]').val();
                        var url ="/generate-report?project_id="+projectId+"&"+dateRangeParams+"&status_id="+status;
                        console.log(url);
                        window.open(url,'_blank');
                    }
                }
            }
        }]
    });
});
