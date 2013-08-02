var $areaChart = undefined;
$(function () {
    $areaChart = new Highcharts.Chart({
        chart: {
            type: 'area',
            zoomType: 'xy',
            renderTo: 'area-container'
        },
        title: {
            text: velocity_Title
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
        yAxis:{
          title: {
              text: "Velocity"
          }
        },
        credits: {
            enabled: false
        },
        series: velocityData
    });
});