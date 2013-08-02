var $mixedChart = undefined;
$(function () {
    $mixedChart = new Highcharts.Chart({
        chart: {
            zoomType: 'xy',
            renderTo:"mixed-container"
        },
        title: {
            text: mixedTitleName
        },
        xAxis: [{
            labels: {
                rotation: -45,
                align: 'right',
                style: {
                    fontSize: '13px',
                    fontFamily: 'Verdana, sans-serif'
                }
            },
            categories: categoryData
        }],
        yAxis: [{ // Secondary yAxis
            gridLineWidth: 0,
            title: {
                text: 'Defects',
                style: {
                    color: '#4572A7'
                }
            },
            labels: {
                formatter: function() {
                    return this.value;
                },
                style: {
                    color: '#4572A7'
                }
            }

        }],
        tooltip: {
            shared: true
        },
        legend: {
            align: 'right',
            x: -100,
            verticalAlign: 'top',
            y: 20,
            floating: true,
            backgroundColor: '#FFFFFF'
        },
        series: [ {
            name: 'Active',
            type: 'spline',
            color: '#AA4643',
            yAxis: 0,
            data: activeData,
            marker: {
                enabled: false
            },
            dashStyle: 'shortdot'
        }, {
            name: 'Arrival Rate',
            color: '#4572A7',
            type: 'column',
            yAxis: 0,
            data: arrivalData
        }, {
            name: 'Kill Rate',
            color: '#89A54E',
            type: 'spline',
            yAxis: 0,
            data: killData
        }]
    });
});
