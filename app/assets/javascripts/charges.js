$(function () {

  /**
   * Clean up state when the modal closes
   * Hide the spinner and message if they are visible
   */
  $('#realexFormModal').on('hidden.bs.modal', function () {
    hideSpinner();
    hideMessage();
  });

  /**
   * Take control of the form submission. Prevent the default submission
   * behaviour
   */
  $('#realex-form').submit( function (e) {
    e.preventDefault();

    // Disable the button to stop the user making multiple requests before
    // completing the current one
    $('#submit-btn').prop("disabled", true);

    // Show the loading spinner
    showSpinner();

    // Charge the user with their inputted details
    createCharge();
  });

  /**
   * This function creates a realex charge request using the realex object.
   * This request will call the realexResponseHandler on completion
   * @method createCharge
   */
  function createCharge() {
    // Send a post request to the charges route
    $.post('/charges', {
      first_name: "john",
      last_name: "doe",
      amount: $('#amount').val(),
      number: $('#card-number').val(),
      cvv: $('#cvv').val(),
      month: $('#expiry-month').val(),
      year: $('#expiry-year').val()
    })
    .done(res => showSuccess(res))
    .fail(err => handleErrors(err.responseJSON))
    .always(function() {
      $('#submit-btn').prop("disabled", false);
    });
  }

  /**
   * Shows the user the success message from the realex_handler module
   * @method showSuccess
   * @param  {}     res     response object returned from the realex purchase
   */
  function showSuccess (res) {
    // Hide the spinner
    hideSpinner();

    // Show the user the success message
    showMessage(res.message);
  };

  /**
   * Sorts through the error retrieved from the realex charge and executes
   * the nessecary methods
   * @method handleErrors
   * @param  {}     err     error object returned from the realex charge
   */
  function handleErrors(err) {
    showMessage(err.message);
  };

  /**
   * Highlight fields with invalid params.
   * @method highlightFields
   * @return []     fields      A list of all the fields to highlight
   */
  function highlightFields(fields) {
    // Highlight specific/all fields
    fields.forEach((element) => {
      $(`#${element}`).css('border', '1px solid red');
    });

    // Hide the spinner if active
    hideSpinner();
  };

  /**
   * Retry the transaction from scratch with the users inputted details.
   * This method should inform the user that the transaction is taking longer
   * than normal/being re-tried.
   * @method retry
   */
  function retry () {
    // Set the amount to a 00 value for a success response
    $('#amount').val(1.00);

    // Wait two seconds to try and avoid any network issues
    setTimeout(() => {
      // Change the message that the user sees
      $('.payment-text').text('Just a little longer .... ');
      createCharge();
    }, 2000);

    // Put the default text back in the payment text section
    $('#payment-text').text('One moment we are processing your request ...');
  };

  /**
   * Show the spinner and hide the form
   * @method showSpinner
   */
  function showSpinner () {
    $('#spinner-container').show();
    $('#realex-form').hide();
  };

  /**
   * Hide the spinner and show the form
   * @method hideSpinner
   */
  function hideSpinner () {
    $('#spinner-container').hide();
    $('#realex-form').show();
  };

  /**
   * Show the user a message based on the error we recieve
   * @method showMessage
   * @param  string     message     The message to show the user
   */
  function showMessage(message) {
    $('#message-text').text(message);

    $('#realex-form').hide();
    $('#spinner-container').hide();
    $('#message-container').show();
  };

  /**
   * Hide the message from the user and show the form again
   * @method hideMessage
   */
  function hideMessage() {
    $('#message-container').hide();
    $('#realex-form').show();
  };
});
