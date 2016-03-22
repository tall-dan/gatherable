var Gatherable = {
  create: function(gatherableVar, options, globalIdentifier = null) {
    var data = {};
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    data[gatherableVar] = options;
    $.ajax({
      url:  '/gatherable/' + pathVar + gatherableVar + 's',
      method: 'POST',
      data: data
    });
  },

  show: function(gatherableVar, id, globalIdentifier = null) {
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's/' + id
    });
  },

  update: function(gatherableVar, id, options, globalIdentifier = null){
    var data = {};
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    data[gatherableVar] = options;
    $.ajax({
      url:  '/gatherable/' + pathVar + gatherableVar + 's',
      method: 'PUT',
      data: data
    });
  },

  index: function(gatherableVar, id, globalIdentifier = null){
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's/'
    });
  },

  destroy: function(gatherableVar, id, globalIdentifier = null) {
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's/' + id,
      method: 'DELETE'
    });
  }
};
