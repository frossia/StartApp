'use strict'
app = angular.module('app', ['ngAnimate'])


##################################################################################
##################################################################################


app.controller 'testCtrl', ($scope, $http, $timeout) ->
  $scope.test = "Test data from ANGULAR"