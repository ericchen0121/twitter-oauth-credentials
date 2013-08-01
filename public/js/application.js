$(document).ready(function() {
  $('form').submit(function(e){
    e.preventDefault();
    console.log('before ajax call');
    $.ajax({
      url: '/tweets',
      type: 'post', 
      data: $('form').serialize(), 
      success: console.log('ajax success')
    }).done();
    })
  });
});

// function(data){
//       console.log(data
