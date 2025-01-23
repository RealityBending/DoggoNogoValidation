// Intro

const rpmInstructions = {
  type: jsPsychSurvey,
  survey_json: {
      showQuestionNumbers: false,
      completeText: "Next",
      pages: [
          {
              elements: [
                  {
                      type: "html",
                      name: "rpmInstructions",
                      html:
                          "<h2 align='center'>Puzzle Task</h2>" +
                          "<p align='center'>We are beginning the <b>puzzle task</b>.</p>" +
                          "<p align='center'>In this task, you will be shown a series of puzzles. For each puzzle, your goal is to</p>" +
                          "<p align='center'>identify the missing piece from the options appearing below the puzzle.</p>" +
                          "<p align='center'>There are 9 puzzles in total. You will have <b>30 seconds</b> for each puzzle.</p>" +
                          "<p align='center'>Try to be as accurate as you can be. If you cannot solve the puzzle before time runs out, then you should guess.</p>" +
                          "<p align='center'>Press the <strong>Next</strong> button to get started.</p>"
                  },
              ],
          },
      ],
  },
  data: {
      screen: "rpmInstructions",
  },
}

//------------------------------------//
// Define parameters.
//------------------------------------//

// Define timing parameters.
var trial_duration = 30000;     // 30 seconds

// Define screen size parameters.
var min_width = 700;
var min_height = 600;

//------------------------------------//
// Define images for preloading.
//------------------------------------//

// Define images to preload
var preload_rpm_tfa = [
  './stimuli/rpm_stimuli/a11.png',
  './stimuli/rpm_stimuli/a24.png',
  './stimuli/rpm_stimuli/a28.png',
  './stimuli/rpm_stimuli/a36.png',
  './stimuli/rpm_stimuli/a43.png',
  './stimuli/rpm_stimuli/a48.png',
  './stimuli/rpm_stimuli/a49.png',
  './stimuli/rpm_stimuli/a53.png',
  './stimuli/rpm_stimuli/a55.png',
  [...Array(6).keys()].map(i => './stimuli/rpm_stimuli/a11_' + (i+1) + '.png'),
  [...Array(6).keys()].map(i => './stimuli/rpm_stimuli/a24_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a28_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a36_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a43_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a48_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a49_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a53_' + (i+1) + '.png'),
  [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a55_' + (i+1) + '.png')
];


var rpmPreload = {
  type: jsPsychPreload,
  images: preload_rpm_tfa,
  message: 'Loading images. This may take a moment depending on your internet connection.',
  error_message: '<p>The experiment failed to load. Please try restarting your browser.</p><p>If this error persists after 2-3 tries, please contact the experimenter.</p>',
  continue_after_error: false,
  show_progress_bar: true,
  max_load_time: 30000
}

//------------------------------------//
// Define RPM task.
//------------------------------------//

// Define task timeline
var timeline_variables_tfa = [
  {
    stimulus: './stimuli/rpm_stimuli/a11.png',
    choices: [...Array(6).keys()].map(i => './stimuli/rpm_stimuli/a11_' + (i+1) + '.png'),
    correct: 4,
    col_wrap: 3
  },
  {
    stimulus: './stimuli/rpm_stimuli/a24.png',
    choices: [...Array(6).keys()].map(i => './stimuli/rpm_stimuli/a24_' + (i+1) + '.png'),
    correct: 4,
    col_wrap: 3
  },
  {
    stimulus: './stimuli/rpm_stimuli/a28.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a28_' + (i+1) + '.png'),
    correct: 7,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a36.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a36_' + (i+1) + '.png'),
    correct: 1,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a43.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a43_' + (i+1) + '.png'),
    correct: 4,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a48.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a48_' + (i+1) + '.png'),
    correct: 5,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a49.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a49_' + (i+1) + '.png'),
    correct: 6,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a53.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a53_' + (i+1) + '.png'),
    correct: 0,
    col_wrap: 4
  },
  {
    stimulus: './stimuli/rpm_stimuli/a55.png',
    choices: [...Array(8).keys()].map(i => './stimuli/rpm_stimuli/a55_' + (i+1) + '.png'),
    correct: 1,
    col_wrap: 4
  },
]


var rpm_task_tfa = {
  timeline: [
    {
      type: jsPsychScreenCheck,
      min_width: min_width,
      min_height: min_height
    },
    {
      type: jsPsychHtmlKeyboardResponse,
      stimulus: '',
      choices: 'NO_KEYS',
      trial_duration: 1200,
      on_start: function(trial) {
        const k = jsPsych.data.get().filter({trial_type: 'rpm', screen: 'rpm'}).count();
        trial.stimulus = `<div style="font-size:24px;">Loading puzzle:<br>${k+1} / 9</div>`;
      }
    },
    {
      type: jsPsychRpm,
      stimulus: jsPsych.timelineVariable('stimulus'),
      choices: jsPsych.timelineVariable('choices'),
      correct: jsPsych.timelineVariable('correct'),
      col_wrap: jsPsych.timelineVariable('col_wrap'),
      countdown: true,
      trial_duration: trial_duration,
      randomize_choice_order: true,
      data: {screen: 'rpm'}
    }
  ],
  timeline_variables: timeline_variables_tfa
}

//------------------------------------//
// Define RPM scoring.
//------------------------------------//

var dot_product = function(x, y) {
  var sum = 0;
  for (let i = 0; i < x.length; i++) { sum += x[i] * y[i]; }
  return sum;
}

var score_rpm_tfa = function() {

  // Summarize RPM.
  const rpm_raw = jsPsych.data.get().filter({trial_type: 'rpm'}).select('accuracy').sum();
  const rpm_err = 9 - rpm_raw;
  const rpm_rt = jsPsych.data.get().filter({trial_type: 'rpm'}).select('rt').sum();

  // Fetch accuracy.
  var accuracy = jsPsych.data.get().filter({trial_type: 'rpm'}).select('accuracy').values;
  var errors = accuracy.map(x => 1 - x);

  // Score RPM (Bilker et al. 2012).
  const weights = [0.198,0.216,0.237,0.142,0.374,0.304,0.178,0.458,0.289];
  var rpm_adj = 60 - (rpm_err + Math.exp(1.323 + dot_product(errors, weights)));

  return {rpm_raw: rpm_raw, rpm_err: rpm_err, rpm_adj:rpm_adj, rpm_rt: rpm_rt};
}

var rpm_score_tfa = {
  type: jsPsychCallFunction,
  func: score_rpm_tfa
}

//------------------------------------//
// Define RPM block
//------------------------------------//

var rpmTask = {
  timeline: [rpm_task_tfa, rpm_score_tfa]
}
