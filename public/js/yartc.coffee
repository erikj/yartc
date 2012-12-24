YARTC = {}
@YARTC = YARTC

# render login view
YARTC.showPartial = (partial) ->
  # replace $('#content') w/ response of '/partial/login'
  $.get '/partial/'+partial,
    '',
    (data) ->
      $('#content').html data


YARTC.login = (username, password, confirmPassword) ->
  # TODO: authenticate


# onload handlers
$ ->
  $('#login-link').click () -> YARTC.showPartial('login')
  $('#signup-link').click () -> YARTC.showPartial('signup')
