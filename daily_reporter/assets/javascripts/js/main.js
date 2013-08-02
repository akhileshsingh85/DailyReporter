/**
 * Created with JetBrains RubyMine.
 * User: amit
 * Date: 6/28/13
 * Time: 5:46 PM
 * To change this template use File | Settings | File Templates.
 */
$(document).ready(function(){
    $('.toggle-setting').click(function(){
        var y = $(this).offset().top;
        var containerWidth = $('.chart-settings').width();
        $('.chart-settings').css({top:y + 30});
        $('.chart-settings').slideToggle()
    });
    var fixHelperModified = function(e, tr) {
            var $originals = tr.children();
            var $helper = tr.clone();
            $helper.children().each(function(index) {
                $(this).width($originals.eq(index).width())
            });
            return $helper;
        },
        updateIndex = function(e, ui) {
            var bind = ui.item.attr('bind');
            var $binded_chart = $('#'+bind+'-container');
            if(ui.item.prev().length){
                 var bind_prev_elem = ui.item.prev().attr('bind');
                 $($binded_chart).insertBefore($('#'+bind_prev_elem+'-container'));
            }else{
                $binded_chart.prependTo($('.chart_container'));
            }

    };

    $('div[id $= "-container"]').each(function(i){
        $(this).attr('index', i);
        var prefix = $(this).attr('id').substring(0, $(this).attr('id').lastIndexOf("-container"));
        var title = $(this).attr('chart_title');
        var sortItem =  '<li><a href="#" class="sort_row selected" bind="'+prefix+'" >'+title+'</a></li>';
        $('.sort_container').append(sortItem);
    });

    /*var $columnSelect = $('<select></select>');
    $columnSelect.addClass('column_select');
    for(var i=1;i<6;i++){
        $columnSelect.append('<option value="'+i+'">'+i+' Columns</option>');
    }
    $columnSelect.insertAfter($('.sort_container'));
    $columnSelect.change(function(){
         $('.chart_container > div').width((100/$(this).val())-1+'%');
        $('.chart_container > div').height($('.chart_container > div').first().width());
        $pieChart.setSize(100, 100);
        $pieChart.redraw();
    });*/

    $('.sort_row').click(function(e){
        e.preventDefault();
        var bind = $(this).attr('bind');
        $(this).toggleClass("selected");
        $('#'+bind+'-container').parent().toggle("fade", 500);
    });

    $(".chart_container").sortable({
        helper: fixHelperModified,
        stop: updateIndex,
        handle:'.drag-chart'
    }).disableSelection();


    $('.ok').click(function(){
        $('.sort_container > .sort_row').each(function(index){
            var prefix = $(this).attr('bind');
            $('div[id $= "'+prefix+'-container"]').attr('index', index);
        });
        $()
    });

    $( "a.drag-chart" ).button({
        icons: {
            primary: "ui-icon-arrow-4"
        },
        text: false,
        title:'Move chart'
    });

    $( "a.resize-chart" ).button({
        icons: {
            primary: "ui-icon-carat-2-e-w"
        },
        text: false,
        title:'Resize chart'
    }).click(function(){
            var chartToUpdate = undefined;
            var chartString = $(this).attr('chart');
            if(chartString == 'pie'){
                 chartToUpdate = $pieChart;
            }else if(chartString == 'mixed'){
                 chartToUpdate = $mixedChart;
            }else if(chartString == 'area'){
                 chartToUpdate = $areaChart;
            }else if(chartString == 'stacked'){
                chartToUpdate = $stackedChart;
            }else if(chartString == 'oibp'){
                chartToUpdate = $oibpChart;
            }else if(chartString == 'oifpm'){
                chartToUpdate = $oifpmChart;
            }else if(chartString == 'rework'){
                chartToUpdate = $reworkChart;
            }
            if($(this).hasClass('wide')){
                $(this).parent().width('48%');
                $(this).parent().height('500px');
                chartToUpdate.setSize(($(this).parent().width()-20), 500);
            }else{
                $(this).parent().width('100%');
                $(this).parent().height('600px');
                chartToUpdate.setSize(($(this).parent().width()-20), 600);
            }
            $('html, body').animate({
                scrollTop: $(this).offset().top - 30
            }, 1000);
            $(this).toggleClass('wide');

        });

    $( ".submit_button" ).button();

});

function getHost(){
    var pathArray = window.location.href.split( '/' );
    var protocol = pathArray[0];
    var host = pathArray[2];
    var url = protocol + '://' + host;
    alert(url);
    return url;
}

function getDateRangeParams(){
    var fromDate = $('input[name="start_date"]').val();
    var toDate = $('input[name="end_date"]').val();
    return "start_date="+fromDate+"&end_date="+toDate;
}