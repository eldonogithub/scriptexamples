import $ from 'jquery';
import dt from 'datatables';
import 'datatables/media/css/jquery.dataTables.css';

// When the DOM is ready  start 
$(document).ready(function() {
  // Handler for displaying the creationDate in human readable form
  function creationDateRenderer(data, type, row, meta) {
    if (type == "display") {
      var d = new Date(data * 1000);
      return d.toISOString();
    }
    // otherwise just return the numeric data
    return data;
  }

  function imsiRenderer(data, type, row, meta) {
    if ( type == "display" ) {
      return "<a href=\"?imsi=" + encodeURIComponent(data) + "\">" + encodeURI(data) + "</a>";
    }
    return data;
  }

  function msisdnRenderer(data, type, row, meta) {
    if ( type == "display" ) {
      return "<a href=\"?msisdn=" + encodeURIComponent(data) + "\">" + encodeURI(data) + "</a>";
    }
    return data;
  }

  // Handle the row click
  function rowClickHandler() {
    // Ask DataTables which data row this is
    var data = dt.row(this).data();

    alert('You clicked the row for MSISDN=' + data.msisdn);
  }

  function ajaxHandler(data, cb, settings) {
    function successHandler(data) {
      if (data.status === 'Success') {
	cb(data);
      } else {
	// error
      }
    }
    // send ajax call
    $.ajax();
  }

  // Prepare the data table rendering
  var dt = $('#example').DataTable({
    ajax : {
      "url" : "/cgi-bin/ajax.pl",
      "method" : "POST"
    },
    serverSide : true,
    pageLength : 10,
    lengthMenu : [ 1, 5, 10, 50, 100, 1000 ],
    regex : true,
    info : false,
    ordering : false,
    pagingType : "simple_numbers",
    columns : [ {
      "title" : "Row",
      "data" : "row"
    }, {
      "title" : "AOR",
      "data" : "aor",
    }, {
      "title" : "IMSI",
      "data" : "imsi",
      render : imsiRenderer
    }, {
      "title" : "MSISDN",
      "data" : "msisdn",
      render : msisdnRenderer
    }, {
      "title" : "Operator ID",
      "data" : "operatorId",
    }, {
      "title" : "Creation Date",
      "data" : "creationDate",
      render : creationDateRenderer
    }, ]
  });

  // Use jQuery's delegated API to apply click handling
  // dt.on('click', 'tr', rowClickHandler);
});
