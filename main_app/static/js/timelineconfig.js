/* Initialize timeline variables */
var GraphItems = new vis.DataSet()

/* TODO: Under Construction -- if item is moved from group to another group, save the transitions to the database */
var ItemChanges = []

/* Temporary variable to gather event information */
var TheText = ''

/* Localize timeline */
if (typeof links === 'undefined') {
  var links = {}
  links.locales = {}
} else if (typeof links.locales === 'undefined') {
  links.locales = {}
};

links.locales['fi'] = {
  'MONTHS': ['tammikuu', 'helmikuu', 'maaliskuu', 'huhtikuu', 'toukokuu', 'kesäkuu', 'heinäkuu', 'elokuu', 'syyskuu', 'lokakuu', 'marraskuu', 'joulukuu'],
  'MONTHS_SHORT': ['tammi', 'helmi', 'maalis', 'huhti', 'touko', 'kesä', 'heinä', 'elo', 'syys', 'loka', 'marras', 'joulu'],
  'DAYS': ['sunnuntai', 'maanantai', 'tiistai', 'keskiviikko', 'torstai', 'perjantai', 'lauantai'],
  'DAYS_SHORT': ['su', 'ma', 'ti', 'ke', 'to', 'pe', 'la'],
  'ZOOM_IN': 'Zoom in',
  'ZOOM_OUT': 'Zoom out',
  'MOVE_LEFT': 'Move left',
  'MOVE_RIGHT': 'Move right',
  'NEW': 'New',
  'CREATE_NEW_EVENT': 'Create new event'
}

/* Localize other timestamps (outside timeline) */
moment.locale('fi')

var MaxDate = new Date(new Date().getTime() + (1 * 365 * 24 * 60 * 60 * 1000)) /* add one year to current date */
var Options = ''
var GrOptions = ''
var GrContainer = ''
var Timeline = ''
var Graph2D = ''
var ExistingGroups = []
var Legend = []
var TimeSpans = ['osastohoito', 'sädehoito', 'sytostaattihoito']
var RemoveText = /()/
var MiddleStart = ''
var DrawnTimeline = ''
var PatientRecords = ''
var HiddenData = []
var DbEvents = []
var DbAnswers = []
var FindProduct = /()/
var FindCareUnit = ''
var FindUnit = ''
var MatchUnit = ''
var Matches = ''
var Match = ''
var Explanations = []
var friend = ''

/* Specify timeline options */
Options = {
  'locale': 'fi',
  'moveable': true,
  'zoomable': true,
  'zoomMin': 5000000,
  'cluster': true,
  'clusterMaxItems': 4,
  'selectable': true,
  'unselectable': true,
  'editable': true,
  'groupsChangeable': true,
  'groupMinHeight': 35,
  'minHeight': 35 * 3,
  'timeChangeable': false,
  'snapEvents': false,
  'eventMargin': 10,
  'eventMarginAxis': 10,
  'stackEvents': true,

  /* Force span for timeline */
  min: new Date(1980, 1, 1),
  max: MaxDate,

  groupsOrder: "hard-code", /* function (a, b) { return b - a}, */
  customStackOrder: function (a, b) { return b - a }
}

GrOptions = {
  /* Force span for timeline */
  min: new Date(1980, 1, 1),
  max: MaxDate,

  /* Force height for curve section */
  height: '140px',
  /*dataAxis: { left: {range: { min:  }}},*/

  legend: true,
  defaultGroup: '',
  drawPoints: {
    onRender: function (item) {
      return item.label != null
    },
    style: 'circle',
    size: 8
  }
}

/* Placeholders */
GrContainer = document.getElementById('lab_visualization')
Timeline = new links.Timeline(document.getElementById('timeline'), Options)

// TODO: CONSIDER TESTING AND PERHAPS CHANGING TO Graph.js INSTEAD OF Vis.js Graph2d.js
// http://almende.github.io/chap-links-library/graph.html

/* Spawn PSA graph points */
//Graph2D = new vis.Graph2d(GrContainer, GraphItems, GrGroups, GrOptions)
Graph2D = new vis.Graph2d(GrContainer, GraphItems, GrOptions)

/* Add legend buttons above timeline container */
$('div.timeline-buttons').append("<button type='button' id='fit' class='btn-sm btn-primary fit'>Sovita</button>")
$('div.timeline-buttons').append("<button type='button' id='show-all' class='btn-sm btn-primary show-all'>Näytä kaikki</button>")
$('div.timeline-buttons').append("<button type='button' id='cluster' class='btn-sm btn-info' rel='tooltip' title='Ryhmittyneet tapahtumat'>X</button>")
$('div.timeline-buttons').append("<button type='button' id='cluster-range' class='btn-sm btn-info' rel='tooltip' title='Ryhmittyneet tapahtumat ja jaksot'>X</button>")

/* Button functionality to hide or show specific elements */
$('button.fit').click(function () { FitTimeline() })
$('button.show-all').click(function () { ResetTimeline() })

/* Add "legend" buttons for clustered events */
$('button#cluster').css('background-color', '#d9d9d9').css('border-color', '#b0b0b0')
$('button#cluster-range').css('background-color', '#b0b0b0').css('border-color', '#b0b0b0')

/* If item is moved from group to another group, save the transitions to the database */
links.events.addListener(Timeline, 'changed', onMove)

/* Call for label functions */
$(window).resize(function () {
  VisLabelSameWidth()
  Timeline.checkResize()
})


/* Actual event listeners, call for functions on event */
Graph2D.on('finishedRedraw', OnChangeGraph)
Graph2D.on('rangechange', OnChangeGraph)
Graph2D.on('rangechanged', OnChangeGraph)

/* Add event listeners to track changes of displaying items, to attach tooltips to visible items */
links.events.addListener(Timeline, 'ready', OnChangedTimeline)
links.events.addListener(Timeline, 'rangechange', OnChangeTimeline)
links.events.addListener(Timeline, 'rangechanged', OnChangedTimeline)
links.events.addListener(Timeline, 'add', OnDoubleClick)
links.events.addListener(Timeline, 'changed', IsChanged)
links.events.addListener(Timeline, 'select', IsSelected)

/* TODO: Fetch also answered forms from database */
/* Fetch timeline elements from database */
GetTimelineData()

/* TODO: make timeline year labels clickable to zoom to that year or starting from that year */
$('.timeline-axis-text').click(function () { console.log("clicked") })
