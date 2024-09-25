// Math utilities =================================================================================
function randomInteger(min = 1, max = 10) {
    return Math.round(Math.random() * (max - min) + min)
}

// Instructions ===================================================================================
// Instructions
var simpleRT_instructions = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <p>In this experiment, a fixation cross (+) will appear in the center 
    of the screen, followed by a red square.</p>
    <p>Whenever the red square appears, 
    press the <strong>Down Arrow</strong> as fast as you can.</p>
    <div style='float: centre;'><img src='stimuli/red_square.png'></img>
    </div>
    <p>Press any key to begin.</p>
    `,
    post_trial_gap: 2000,
}

// Debrief
// TO DO : ADD ANY FURTHER DETAILS, E.G., LINK??
var simpleRT_debrief = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var trials = jsPsych.data.get().filter({ screen: "response" })
        var correct_trials = trials.filter({ correct: true })
        // var accuracy = Math.round(correct_trials.count()/trials.count()*100);
        var rt = Math.round(correct_trials.select("rt").mean())

        return `
        <p>Your average response time was ${rt}ms.</p>
        <p>Press any key to complete the experiment. Thank you!</p>`
    },
}

// Post-task assessment ==============================================================================

// Questions
var simpleRT_assessment = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Post experiment questions",
        completeText: "Continue",
        pageNextText: "Next",
        pagePrevText: "Previous",
        goNextPageAutomatic: false,
        showQuestionNumbers: false,
        showProgressBar: "aboveHeader",
        pages: [
            {
                elements: [
                    {
                        type: "text",
                        title: "Without checking, how long do you feel you spent on this task? Please answer in minutes.",
                        name: "duration_estimate",
                        isRequired: true,
                        inputType: "number",
                        min: 0,
                        max: 100,
                        placeholder: "Time in minutes (e.g., 5)",
                    },
                ],
            },
            {
                elements: [
                    {
                        title: "How would you feel if you had to do the task again?",
                        name: "repeat_desirability",
                        type: "rating",
                        minRateDescription: "Very annoyed",
                        maxRateDescription: "Very happy",
                        isRequired: true,
                    },
                ],
            },
        ],
    },
    data: {
        screen: "post_qs",
    },
}

// Experiment =====================================================================================
// Fixation trials
var fixation = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: ["ArrowDown"],
    trial_duration: function () {
        var prev_trial_data = jsPsych.data.get().last(1).values()[0]
        if (prev_trial_data.premature_response == true) {
            return prev_trial_data.fixation_duration
        } else {
            var fx_vals = []
            var n = 0
            while (lower_isi + n * isi_steps <= upper_isi) {
                fx_vals.push(lower_isi + n * isi_steps)
                var n = n + 1
            }
            var trial_isi = jsPsych.randomization.sampleWithoutReplacement(fx_vals, 1)[0]
            return trial_isi
        }
    },
    data: {
        screen: "fixation",
    },
    on_start: function (trial) {
        trial.data.fixation_duration = trial.trial_duration
    },
    on_finish: function (data) {
        data.premature_response = data.response !== null
    },
}

var fixation_procedure = {
    timeline: [fixation],
    loop_function: function (data) {
        var last_fx_trial = jsPsych.data.get().last(1).values()[0]
        return last_fx_trial.premature_response
    },
}

// RT trials
var test = {
    type: jsPsychImageKeyboardResponse,
    stimulus: jsPsych.timelineVariable("stimulus"),
    choices: ["ArrowDown"],
    trial_duration: max_rt,
    data: {
        screen: "response",
        correct_response: jsPsych.timelineVariable("correct_response"),
    },
    on_finish: function (data) {
        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response)
    }, // too slow -> correct = false
}

// Linking fixation and RT trials
var test_procedure = {
    timeline: [fixation_procedure, test],
    timeline_variables: test_stimuli,
    randomize_order: true,
    repetitions: n_trials,
}

// // Fixation trials
// const simpleRT_FixationCross = {
//     type: jsPsychHtmlKeyboardResponse,
//     stimulus: '<div style="font-size:80px;">+</div>',
//     choices: ["ArrowDown"],
//     trial_duration: function () {
//         return 2000 // randomInteger(600, 1100)
//     },
//     save_trial_parameters: {
//         trial_duration: true,
//     },
//     data: {
//         screen: "SimpleRT_FixationCross",
//     },
//     response_ends_trial: true,
// }

// // Early response conditionally looping timeline
// const simpleRT_TimelineFixationCross = {
//     timeline: [FixationCross],
//     loop_function: function (data) {
//         // If no response (good trial), don't repeat
//         if (jsPsych.pluginAPI.compareKeys(data.values()[0].response, null)) {
//             return false
//         } else {
//             return true
//         }
//     },
// }

// const simpleRT_Stimulus = {
//     type: jsPsychImageKeyboardResponse,
//     stimulus: "stimuli/red_square.png",
//     choices: ["ArrowDown"],
//     trial_duration: 5000, // Max RT
//     response_ends_trial: true,
//     data: {
//         screen: "SimpleRT_Stimulus",
//     },
//     on_finish: function (data) {
//         data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response)
//     }, // too slow -> correct = false
// }

// // Main timeline
// const SimpleRT = {
//     timeline: [TimelineFixationCross, Stimulus],
//     randomize_order: true,
//     repetitions: 3,
// }
