$('[data-toggle=collapse]').click(function() {
    $(this).find("span").toggleClass("amiq_definition");
});

$('.select2').select2({
    placeholder : '',
    minimumInputLength : 3,
    theme : "bootstrap"
});

$('button[data-select2-open]').click(function() {
	$('#' + $(this).data('select2-open')).select2('open');
});

$("#toc-search").on("change", function(e) {
	console.log(parent);
	console.log(window.top);
    parent.location.href = $(this).val();
	window.top.location.href = $(this).val();
});
