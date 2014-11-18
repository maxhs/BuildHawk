// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var stripeResponseHandler = function(status, response) {
	var form = $('#payment-form');
	if (response.error) {
	    form.find('.payment-errors').text(response.error.message);
	    form.find('button').prop('disabled', false);
	} else {
	    var token = response.id;
	    form.append($('<input type="hidden" name="stripeToken" />').val(token));
	    form.get(0).submit();
	}
};

function stripe(key) {
	var form = $('#payment-form');
	$('input.cc-number').payment('formatCardNumber');
	$('input.cc-expiry').payment('formatCardExpiry');
	$('input.cc-cvc').payment('formatCardCVC');

	form.submit(function(event) {
		if (!$.payment.validateCardNumber($('input.cc-number').val() ) ){
			form.find('.payment-errors').text("Your card number isn't in a valid format.");
    		form.find('.payment-errors').show();
			event.preventDefault();
		    return false;
		} else if (!$.payment.validateCardCVC($('input.cc-cvc').val() ) ){
			form.find('.payment-errors').text("Your cvc is not valid.");
    		form.find('.payment-errors').show();
			event.preventDefault();
		    return false;
		} else {
		    $('.cc-submit').val('Reserving...');
		    form.find('button').prop('disabled', true);
		    Stripe.setPublishableKey(key);
		    expiration = $('.cc-expiry').payment('cardExpiryVal');
		    Stripe.card.createToken({
			  	number: $('.cc-number').val(),
			  	cvc: $('.cc-cvc').val(),
			  	exp_month: (expiration.month || 0),
    			exp_year: (expiration.year || 0)
			}, stripeResponseHandler);
		    event.preventDefault();
		    return false;
		}
	});
}

function setupBilling(invoice_url){
	$('.current-page').removeClass('current-page');
	$('#billing-link').addClass('current-page');
	
	if (invoice_url){
		$('#view-invoice-link').click(function(e){
			e.preventDefault();
			var stuff = $('#past-invoices').val();
			$(this).attr('href',invoice_url+stuff);
			window.open(invoice_url+stuff);
			//$(this).click();
		});
	}
	$(document).ready(function() {
		$('#payment-form').submit(function(event) {
		    var form = $(this);
		    form.find('button').prop('disabled', true);
		    var token = Stripe.card.createToken(form, stripeResponseHandler);
		    event.preventDefault();
		    return false;
		});
	});
}