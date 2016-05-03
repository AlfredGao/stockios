var flag = 0;
var localhost = "http://socketsearch-1272.appspot.com/index.php";
var googlehost = "http://socketsearch-1272.appspot.com/index.php";




function deltr(deltn){
    var symbl = $(deltn).parents("tr").find("#symbol_nam").text();
    console.log(symbl);

    for(var i = 0;i < localStorage.length;i++){
        if(localStorage.getItem(localStorage.key(i)) === symbl){
            localStorage.removeItem(localStorage.key(i));
        }
    }

    $(deltn).parents("tr").remove();
}

function reFresh(){
        $(".fav_col").each(function(){
            var symbl = $(this).find("#symbol_nam").text();
            var mythis = $(this);
            console.log(symbl);
            $.ajax({
                    url: localhost,
                    type: "GET",
                    data: {symbol: symbl},
                    
                    success: function(data) {
                        var obj = $.parseJSON(data);
                        if(obj.Status == "SUCCESS") {
                            //console.log(obj);
                            console.log(obj.LastPrice);
                            mythis.find("#price").html(obj.LastPrice);
                            mythis.find("#change").html(showChange(obj));

                        }
                    },
                    error: function(xhr, status, error) {
                        alert(status);
                    }
            });
        });
}
function loadFav(){
        emptyFav();
        var result = [];
        var myVar = "";
        for(key in localStorage){
            result.push(key);
        }

        result.sort(function(a,b){
            return a - b;
        });

        for(var i = 0;i < result.length;i++){
            $.ajax({
                    url: googlehost,
                    type: "GET",
                    data: {symbol: localStorage.getItem(result[i])},
                    async: false,
                    
                    success: function(data) {
                        var obj = $.parseJSON(data);
                        if(obj.Status == "SUCCESS") {
                            //console.log(obj);
                            showFav(obj);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert(status);
                    }
            });
        }
        $(".fav_name").click(function(){
        var symbl = $(this).parents("tr").find("#symbol_nam").text();
        console.log(symbl);
        paintList(symbl);
        });

        $("#refresh_button").click(function(){
            reFresh();
        });

        $("#automatic_button").change(function(){
            if($(this).prop("checked") === true){
                console.log("flag");
                myVar = setInterval(function(){
                            reFresh();
                        },5000);
            }
            else{
                clearInterval(myVar);
            }
        });
}

function paintList(dataParse){
     $.ajax({
                url: googlehost,
                type: "GET",
                data: {symbol: dataParse},
                    
                success: function(data) {
                    var obj = $.parseJSON(data);
                    if(obj.Status == "SUCCESS") {
                        emptyContent();
                        showList(obj);
                        $("#stock_carousel").carousel(1);
                    }
                },
                error: function(xhr, status, error) {
                    alert(status);
                }
            });
}


$(document).ready(function () {
    loadFav();
    $('[data-tooltip="tooltip"]').tooltip();
    
    $("#clear_but").click(function(){
        $("#stock_carousel").carousel(0);
        emptyContent();
        $("#next_button").off("click");
        $("#next_button").attr("class","btn btn-primary disabled");


    });
    $("#form_main").submit(function(event){
        event.preventDefault();
        var check = $("#search_form").val();
        if(flag == 0 && check != null){
            $("#error").show();
        }
        else if(flag == 1 && check == "undefined - undefined (undefined)"){
            $("#error").show();
            flag = 0;
        }
        else{
            flag = 0;
            console.log(check);
            paintList(check);
    
        }
    });


});

 
 

$(function() {
    $("#search_form")
        .focus()
        .autocomplete({
            source: function(request,response) {
            $.ajax({
                    url: localhost,
                    type: "GET",
                    data: {
                        input: request.term
                    },
                    success: function(data) {
                        var obj = $.parseJSON(data);
                        //console.log(data);
                        response( $.map(obj, function(item) {
                            return {
                                label: item.Symbol + " - " + item.Name + " (" +item.Exchange+ ")",
                                value: item.Symbol
                            }
                        }));
                        //$("span.help-inline").hide();
                        }
                    });
            },
            minLength: 0,
            select: function( event, ui ) {
                    //console.log(ui.item);
                    //$("span.label-info").html("You selected " + ui.item.label).fadeIn("fast");
                    flag = 1;
                    $("#error").hide();

            },
            open: function() {
                    //$(this).removeClass("ui-corner-all").addClass("ui-corner-top");
            },
            close: function() {
                    //$(this).removeClass("ui-corner-top").addClass("ui-corner-all");
            }
        })
        $("#stock_carousel").carousel({interval:false});

        $(".item1").click(function(){
            $("#stock_carousel").carousel(0);
        });

        $(".item2").click(function(){
            $("#stock_carousel").carousel(1);
        });

        $("#prev_button").click(function(){
            $("#stock_carousel").carousel("prev");
            loadFav();
        });
});

function emptyFav(){
    $("#fav_table_1").empty();
    var text = "<tr><th>Symbol</th><th>Company</th><th>Stock Price</th><th>Change (Change Percent)</th><th>Market Cap</th><th></th></tr>";
    $("#fav_table_1").append(text);
}




function showFav(data,num){
   
    var text = "<tr class=\"fav_col\"><td id=\"symbol_nam\"><a href = \"#\" class=fav_name>";
    text += data.Symbol+"</a></td>";
    text += "<td>" + data.Name + "</td>"
    text += "<td id = \"price\">" + data.LastPrice + "</td>";
    text += "<td id =\"change\">" + showChange(data) + "</td>";
    text += "<td>" + capFormat(data) + "</td>";
    text += "<td><button type=\"button\" class=\"btn btn-default\" id=\"remove_but\" onclick = \"deltr(this)\"><span class=\"glyphicon glyphicon-trash\"></span></td></tr>";
    $("#fav_table_1").append(text);

}




function timeTrans(obj){
    var date = moment(obj.Timestamp);
    date = date.format("DD MMMM YYYY,hh:mm:ss a");
    return date;
}




function capFormat(obj){
    var cap = obj.MarketCap;
    if(cap < 1000000){
        return cap;
    }
    else if (cap >= 1000000 && cap < 1000000000){
        cap = cap/1000000;
        cap = cap.toFixed(2);
        cap += " Million";
        return cap;
    }
    else{
        cap = cap/1000000000;
        cap = cap.toFixed(2);
        cap += " Billion";
        return cap;
    }

}




function showChange(obj){
    var check = obj.ChangePercent;
    var percent = obj.ChangePercent.toFixed(2);
    if(check > 0){
        var text = "<span style = \"color:green\">"+obj.Change.toFixed(2) + " ( "+ percent + "% )<img src = \"pic/up.png\"></span>";
        return text;
    }
    else if(check == 0){
        var text = "<span>"+obj.Change.toFixed(2) + " ( "+ percent + "% )</span>";
    }
    else{
         var text = "<span style = \"color:red\">"+obj.Change.toFixed(2) + " ( "+ percent + "% )<img src = \"pic/down.png\"></span>";
         return text;
    }
}




function showYTD(obj){
    var percent = obj.ChangePercentYTD.toFixed(2);
    if(percent > 0){
        var text = "<span style = \"color:green\">"+obj.ChangeYTD.toFixed(2) + " ( "+ percent + "% )<img src = \"pic/up.png\"></span>";
        return text;
    }
    else if(percent == 0){
        var text = "<span>"+obj.ChangeYTD.toFixed(2) + " ( "+ percent + "% )</span>";
    }
    else{
         var text = "<span style = \"color:red\">"+obj.ChangeYTD.toFixed(2) + " ( "+ percent + "% )<img src = \"pic/down.png\"></span>";
         return text;
    }
}




function detailTable(obj){
    var text = "";
    text += "<table class=\"table table-striped\" id=\"stock_detail_table\"><tr><td id=\"sd_td\">Name</td>";
    text += "<td>"+obj.Name+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Symbol</td>";
    text += "<td>"+obj.Symbol+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Last Price</td>";
    text += "<td>"+obj.LastPrice+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Change (Change Percent)</td>";
    text += "<td id=\"td_change\">"+showChange(obj)+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Time and Date</td>";
    text += "<td id=\"time_stamp\">" + timeTrans(obj) + "</td></tr>";
    text += "<tr><td id=\"sd_td\">Market Cap</td>";
    text += "<td id=\"mar_cap\">" + capFormat(obj) + "</td></tr>";
    text += "<tr><td id=\"sd_td\">Volume</td>";
    text += "<td>"+obj.Volume+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Change YTD (Change Percent YTD)</td>";
    text += "<td id=\"YTD\">" + showYTD(obj) + "</td></tr>";
    text += "<tr><td id=\"sd_td\">High Price</td>";
    text += "<td>$ "+obj.High.toFixed(2)+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Low Price</td>";
    text += "<td>$ "+obj.Low.toFixed(2)+"</td></tr>";
    text += "<tr><td id=\"sd_td\">Opening Price</td>";
    text += "<td>$ "+obj.Open.toFixed(2)+"</td></tr>";
    text += "</table>";
    return text;
}




function emptyContent(){
    $("div#detail_header").empty();
    $("div#fb_button").empty();
    $("div#fav_button").empty();
    $("div#details_table").empty();
    $("div#details_charts").empty();
}




function searchData(data){
    for(var i = 0;i < localStorage.length;i++){
        if(localStorage.getItem(localStorage.key(i)) == data.Symbol){
            return true;
        }
    }
    return false;
}


function myFacebookLogin(data) {
    var img = "http://chart.finance.yahoo.com/t?s=" + data.Symbol + "&lang=en-US&width=400&height=300";
    var title = "Current Stock Price of "+data.Name+" is $"+data.LastPrice.toFixed(2);
    var des = "Stock Information of " + data.Name + "(" + data.Symbol + ")";
    var site = "LAST TRADED PRICE: $ " + data.LastPrice.toFixed(2) + ", CHANGE: " + showFBChange(data);
    var linker =" http://dev.markitondemand.com/";
    FB.login(function(response){
        if (response.authResponse) {
            FB.ui({
                method: 'feed',
                picture:   img,
                name:    title,
                caption:   des,
                description:  site,
                link:      linker
        }, function(response){
                            // Debug response (optional)
                if (response && !response.error_message) {
                    alert("Posted Successfully");
                }
                else{
                    alert("Not Posted");
                }
                console.log(response);
            });
    }
        else{

            }
},{
    scope:'publish_actions',
    return_scope: true
    });
}


function showFBChange(data){
    var percent = data.ChangePercent.toFixed(2);
    var text = data.ChangeYTD.toFixed(2) + " ("+ percent + "%)";
    return text;
}


function changeMeta(data){
    var img = "http://chart.finance.yahoo.com/t?s=" + data.Symbol + "&lang=en-US&width=400&height=300";
    var title = "Current Stock Price of "+data.Name+" is $"+data.LastPrice.toFixed(2);
    var des = "Stock Information of " + data.Name + "(" + data.Symbol + ")";
    var site = "LAST TRADED PRICE: $ " + data.LastPrice.toFixed(2) + ", CHANGE: " + showFBChange(data);
    $("meta[property='og:image']").attr('content',img);
    $("meta[property='og:title']").attr('content',title);
    $("meta[property='og:description']").attr('content',des);
    $("meta[property='og:site_name']").attr('content',site);
}

function showList(data){
    console.log(data);
    var flag = 0;
    var table = detailTable(data);
    var img = "<img class = \"img-responsive\"src=\"http://chart.finance.yahoo.com/t?s=" + data.Symbol + "&lang=en-US&width=400&height=300\">";
    $("div#detail_header").text("Stock Details");
    $("div#fb_button").append("<button class = \"btn btn-default\" id=\"fb_icon\"><img src=\"pic/facebook.png\" id=\"fb_img\"></button>");
    if(searchData(data) == false){
        $("div#fav_button").append("<button class = \"btn btn-default\" id=\"fav_icon\"><span class=\"glyphicon glyphicon-star\"id=\"fav_star\"></span></button>");
    }
    else{
        $("div#fav_button").append("<button class = \"btn btn-default\" id=\"fav_icon\"><span style = \"color:yellow\"class=\"glyphicon glyphicon-star\"id=\"fav_star\"></span></button>");
        flag = 1;
    }
    $("#next_button").attr("class","btn btn-primary");
    $("div#details_table").append(table);
    $("div#details_charts").append(img);
    $("#fav_icon").click(function(){

        if(flag == 0){
            $("#fav_star").css("color","yellow");
            flag = 1;
        }
        else{
            $("#fav_star").css("color","white");
            flag = 0;
        }
        if(typeof(Storage) !== "undefined"){
            if(flag == 1){
                var timestamp=new Date().getTime();
                localStorage.setItem(timestamp,data.Symbol);
            }
            else{
                for(var i = 0;i < localStorage.length;i++){
                    if(localStorage.getItem(localStorage.key(i)) == data.Symbol){
                        localStorage.removeItem(localStorage.key(i));
                    }
                }
            }
        }
        else{
            alert("This browser doesnt support local storage");
        }
    });

    $("#fb_icon").click(function(){
        myFacebookLogin(data);
    });


    $("#next_button").click(function(){
            $("#stock_carousel").carousel("next");
        });

    drawHistory(data);

    displayNews(data);

}

function displayNews(data){
 $.ajax({
                url: googlehost,
                type: "GET",
                data: {symbol_name: data.Symbol},
                    
                success: function(data) {
                    
                    //console.log($.parseJSON(data));
                    var obj = $.parseJSON(data);
                    console.log(obj);
                   displayNewsTable(obj);
                    
                },
                error: function(xhr, status, error) {
                    alert(status);
                }
            });   
}

function displayNewsTable(obj){
    $("#news_feed").empty();
    console.log(obj.d.results);
    var array = obj.d.results;
    for(var i = 0;i < 5;i++){
        console.log(array[i]);
        console.log(timeTrans(array[i].Date));
        var data = array[i];
        var text = "<div class=\"panel panel-default\"><div class=\"panel panel-body\" id=\"news_pannel\"><div><p><a href = \"" + data.Url + "\" id = \"new_link\">" + data.Title + "</a></P></div> ";
            text += "<div><p>" + data.Description + "</p></div>";
            text += "<div id=\"new_pub\"><p>Publisher: " + data.Source + "</p></div";
            text += "<div id=\"new_date\"><p>Date" + timeTrans(data.Date) + "</P></div></div></div>";
            $("#news_feed").append(text);                                                           
    }
}


function drawHistory(data){
    $("#his_charts").empty();
    new Markit.InteractiveChartApi(data.Symbol,1095);
}


var Markit = {};
/**
 * Define the InteractiveChartApi.
 * First argument is symbol (string) for the quote. Examples: AAPL, MSFT, JNJ, GOOG.
 * Second argument is duration (int) for how many days of history to retrieve.
 */
Markit.InteractiveChartApi = function(symbol,duration){
    this.symbol = symbol.toUpperCase();
    this.duration = duration;
    this.PlotChart();
};

Markit.InteractiveChartApi.prototype.PlotChart = function(){
    
    var params = {
        parameters: JSON.stringify( this.getInputParams() )
    }

    //Make JSON request for timeseries data
    $.ajax({
        beforeSend:function(){
            $("#chartDemoContainer").text("Loading chart...");
        },
        data: params,
        url: googlehost,
        type: "GET",
        context: this,
        success: function(json){
            //Catch errors
            var data = $.parseJSON(json);
            console.log(data);
            if (!data || data.Message){
                console.error("Error: ", data.Message);
                return;
            }
            this.render(data);
        },
        error: function(response,txtStatus){
            console.log(response,txtStatus)
        }
    });
};

Markit.InteractiveChartApi.prototype.getInputParams = function(){
    return {  
        Normalized: false,
        NumberOfDays: this.duration,
        DataPeriod: "Day",
        Elements: [
            {
                Symbol: this.symbol,
                Type: "price",
                Params: ["ohlc"] //ohlc, c = close only
            },
            {
                Symbol: this.symbol,
                Type: "volume"
            }
        ]
        //,LabelPeriod: 'Week',
        //LabelInterval: 1
    }
};

Markit.InteractiveChartApi.prototype._fixDate = function(dateIn) {
    var dat = new Date(dateIn);
    return Date.UTC(dat.getFullYear(), dat.getMonth(), dat.getDate());
};

Markit.InteractiveChartApi.prototype._getOHLC = function(json) {
    var dates = json.Dates || [];
    var elements = json.Elements || [];
    var chartSeries = [];

    if (elements[0]){

        for (var i = 0, datLen = dates.length; i < datLen; i++) {
            var dat = this._fixDate( dates[i] );
            var pointData = [
                dat,
                elements[0].DataSeries['open'].values[i]
                //elements[0].DataSeries['high'].values[i],
                //elements[0].DataSeries['low'].values[i],
                //elements[0].DataSeries['close'].values[i]
            ];
            chartSeries.push( pointData );
        };
    }
    return chartSeries;
};

Markit.InteractiveChartApi.prototype._getVolume = function(json) {
    var dates = json.Dates || [];
    var elements = json.Elements || [];
    var chartSeries = [];

    if (elements[1]){

        for (var i = 0, datLen = dates.length; i < datLen; i++) {
            var dat = this._fixDate( dates[i] );
            var pointData = [
                dat,
                elements[1].DataSeries['volume'].values[i]
            ];
            chartSeries.push( pointData );
        };
    }
    return chartSeries;
};

Markit.InteractiveChartApi.prototype.render = function(data) {
    //console.log(data)
    // split the data set into ohlc and volume
    var ohlc = this._getOHLC(data),
        volume = this._getVolume(data);

    // set the allowed units for data grouping
    var groupingUnits = [[
        'week',                         // unit name
        [1]                             // allowed multiples
    ], [
        'month',
        [1, 2, 3, 4, 6]
    ]];

    // create the chart
    $("div#his_charts").highcharts('StockChart', {
        
        rangeSelector: {
            selected: 0,
            //enabled: false
            buttons: [{
                type: 'week',
                count: 1,
                text: '1w'
            }, {
                type: 'month',
                count: 1,
                text: '1m'
            }, {
                type: 'month',
                count: 3,
                text: '3m'
            },{
                type:'month',
                count:6,
                text:'6m'

            }, {
                type: 'year',
                count: 1,
                text: '1y'
            }, 
            {
                type: 'ytd',
                text: 'YTD'
            },{
                type: 'all',
                text: 'All'
            }]

        },

        title: {
            text: this.symbol + ' Stock Value'
        },

        yAxis: [{
            title: {
                text: 'OHLC'
            },
            height: 200,
            lineWidth: 2
        }],
        
        series: [{
            type: 'area',
            name: this.symbol,
            data: ohlc,
            dataGrouping: {
                units: groupingUnits
            },
            tooltip: {
                valueDecimals: 2,
                valuePrefix: "$"
            },
            fillColor : {
                linearGradient : {
                    x1: 0,
                    y1: 0,
                    x2: 0,
                    y2: 0

                },
                stops : [
                    [0, Highcharts.getOptions().colors[0]],
                    [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                ]
            }
        }],
        credits: {
            enabled:true
        }
    });
};










