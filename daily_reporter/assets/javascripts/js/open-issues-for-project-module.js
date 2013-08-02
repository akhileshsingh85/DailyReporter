var $oifpmChart = undefined;
$(function () {

    $oifpmChart = new Highcharts.Chart({
        chart: {
            type: 'line',
            renderTo:'open-issues-for-project-module-container'
        },
        title: {
            text: openIssuesForProjectModule_Title
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
                text: 'Issues Count'
            },
            stackLabels: {
                enabled: true,
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
                    this.series.name +': '+ this.y +'<br/>'
            }
        },
        plotOptions: {
            column: {
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                },
                point:{
                    events:{
                        click:function(){
                            console.log(this.series.name);
                            console.log(this.category);
                            var projectId = $('input[name="projectId"]').val();
                            var url ="/generate-report?selected_date='"+this.category+"'&priority_id="+this.series.name
                                +"&project_id="+projectId;
                            console.log(url);
                            alert(url);
                            window.open(url,'_blank');
                        }
                    }

                }
            }
        },
        series: openIssuesForProjectModule_Data
    });
});