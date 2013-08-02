var $reworkChart = undefined;
$(function () {
    $reworkChart = new Highcharts.Chart({
        chart: {
            type: 'area',
            zoomType: 'xy',
            renderTo:'rework-container'
        },
        title: {
            text: reworkPercentageTitle
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
        credits: {
            enabled: false
        },
        series: reworkPercentageData
    });
});
