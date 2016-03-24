var Gatherable = {
  create: function(gatherableVar, options, globalIdentifier) {
    var data = {};
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    data[gatherableVar] = options;
    $.ajax({
      url:  '/gatherable/' + pathVar + gatherableVar + 's.json',
      method: 'POST',
      data: data
    });
  },

  show: function(gatherableVar, id, globalIdentifier) {
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's/' + id + '.json'
    });
  },

  update: function(gatherableVar, id, options, globalIdentifier){
    var data = {};
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    data[gatherableVar] = options;
    $.ajax({
      url:  '/gatherable/' + pathVar + gatherableVar + 's/' + id + '.json',
      method: 'PUT',
      data: data
    });
  },

  index: function(gatherableVar, globalIdentifier){
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's.json'
    });
  },

  destroy: function(gatherableVar, id, globalIdentifier) {
    pathVar = globalIdentifier ? globalIdentifier + '/' : ''
    $.ajax({
      url: '/gatherable/' + pathVar + gatherableVar + 's/' + id + '.json',
      method: 'DELETE'
    });
  }
};
