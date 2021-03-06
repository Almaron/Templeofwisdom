@app.controller "ForumsCtrl", ["$scope", "$http", '$q', "Forum", ($scope, $http, $q, Forum) ->

  $scope.forumPagination = {}
  $scope.toForumId = 0
  $scope.loadedForum = false
  $scope.loadedTopics = false
  $scope.unread_forums = []
  $scope.unread_topics = []

  $http.get('/temple/forum_reads.json').success (data) ->
    $scope.unread_forums = data


  $http.get('/temple/move_topic.json').success (data) ->
    $scope.all_forums = data

  $scope.loadRoot = ->
    $scope.forums = Forum.query()

  $scope.initForum = (forum_id, page) ->
    $scope.forum_id = forum_id
    $scope.loadForum(forum_id, page)

  $scope.loadForum = (id, page) ->
    data = Forum.get {id:id}, ->
      $scope.forum = data.forum
      $scope.path = data.path
      $scope.forumPagination.cur = page unless $scope.forum.isCategory
      $scope.loadedForum = true
    $http.get('/temple/forum_reads/'+id+'.json').success (data) ->
      $scope.unread_topics = data



  $scope.$watch "forumPagination.cur", (newVal) ->
    $scope.loadTopics(newVal) unless typeof(newVal) == "undefined"

  $scope.loadTopics = (page) ->
    $scope.loadedTopics = false
    $http.get("/temple/"+$scope.forum_id+"/t.json?page="+page).success (data)->
      $scope.topics = data.topics
      $scope.forumPagination.total = data.total
      $scope.loadedTopics = true

  selected = 0

  breakSelect = ->
    selected = 0
    angular.element($('#selectAll')).attr('checked',false)
    $scope.loadTopics($scope.forumPagination.cur)

  $scope.clickModerate = ->
    $scope.moderateOn = !$scope.moderateOn
    if $scope.moderateOn
      $scope.moderateForums = $scope.all_forums
    else
      $scope.moderateForums = []
      selected = 0
      angular.element($('#selectAll')).attr('checked',false)


  $scope.selectAll = ->
    selected = (selected + 1) % 2
    angular.forEach $scope.topics, (topic) ->
      topic.selected = selected

  $scope.moveTopics = ->
    $scope.moderateProgress = true
    toForumId = $scope.toForumId
    if toForumId == $scope.forum_id
      alert 'Некуда переносить!'
      return
    posts = []
    angular.forEach $scope.topics, (topic) ->
      if topic.selected == 1
        posts.push $http.put('/temple/move_topic.json', { topic_id: topic.id, to_forum_id: toForumId })
    $q.all(posts).then ->
      $scope.toForumId = null
      breakSelect()
      $scope.moderateProgress = false


  $scope.deleteTopics = ->
    if confirm('Уверены?')
      $scope.moderateProgress = true
      ids = []
      angular.forEach $scope.topics, (topic) ->
        if topic.selected == 1
          ids.push topic.id
      $http.delete('/temple/move_topic.json?forum_id='+$scope.forum_id+'&delete_topics='+ids.join(',')).success (data) ->
        $scope.loadTopics $scope.forumPagination.cur
        $scope.moderateProgress = false

  $scope.openTopics = ->
    posts = []
    $scope.moderateProgress = true
    angular.forEach $scope.topics, (topic) ->
      if topic.selected == 1
        posts.push $http.put('/temple/'+$scope.forum_id+'/t/'+topic.id+'.json', { topic: { closed: 0 } })
    $q.all(posts).then ->
      breakSelect()
      $scope.moderateProgress = false


  $scope.closeTopics = ->
    posts = []
    $scope.moderateProgress = true
    angular.forEach $scope.topics, (topic) ->
      if topic.selected == 1
        posts.push $http.put('/temple/'+$scope.forum_id+'/t/'+topic.id+'.json', { topic: { closed: 1 } })
    $q.all(posts).then ->
      breakSelect()
      $scope.moderateProgress = false

  $scope.readAllTopics = ->
    $http.post('/temple/forum_reads.json').success (data) ->
      $scope.unread_forums = []

  $scope.readTopics = (forum_id) ->
    $http.post('/temple/forum_reads.json', {forum: forum_id}).success (data) ->
      $scope.unread_topics = []

  $scope.forumClass = (forum) ->
    if $scope.unread_forums.indexOf(forum.id) > -1
      si = 'unread'
    else
      si = 'read'
    'forum-f-'+si

  $scope.topicClass = (topic) ->
    if $scope.unread_topics.indexOf(topic.id) > -1
      si = 'unread'
    else
      si = 'read'
    if topic.closed
      sc = '-locked'
    else
      sc = ''
    'forum-topic-'+si+sc

]
