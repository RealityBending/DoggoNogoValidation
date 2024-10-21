// Math utilities =================================================================================
function randomInteger(min = 1, max = 10) {
    return Math.round(Math.random() * (max - min) + min)
}

// Instructions ===================================================================================
// Instructions
const simpleRT_instructions = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <p>In this experiment, a fixation cross (+) will appear in the center 
    of the screen, followed by a red square.</p>
    <p>Whenever the red square appears, 
    press the <strong>Down Arrow</strong> as fast as you can.</p>
    <div style='float: centre;'><img src='stimuli/red_square.png'></img>
    </div>
    <p>Press the <b>down arrow</b> to begin.</p>
    `,
    post_trial_gap: 2000,
}

// Debrief
// TO DO : ADD ANY FURTHER DETAILS, E.G., LINK??
const simpleRT_debrief = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var trials = jsPsych.data.get().filter({ screen: "response" })
        var correct_trials = trials.filter({ correct: true })
        var rt = Math.round(correct_trials.select("rt").mean())

        return `
        <p>Your average response time was ${rt}ms.</p>
        <p>Press any key to complete the experiment. Thank you!</p>`
    },
}

// Post-task assessment ==============================================================================

// Questions
const simpleRT_assessment = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Feedback",
        completeText: "Continue",
        pageNextText: "Next",
        pagePrevText: "Previous",
        goNextPageAutomatic: true,
        showQuestionNumbers: false,
        pages: [
            {
                elements: [
                    {
                        title: "How much did you enjoy the previous task?",
                        name: "TaskFeedback_Enjoyment",
                        type: "rating",
                        minRateDescription: "Boring",
                        maxRateDescription: "Fun",
                        rateType: "stars",
                        rateMin: 0,
                        rateMax: 7,
                        isRequired: true,
                    },
                    {
                        type: "text",
                        title: "Without checking the time, how long do you think you spent doing the previous task?",
                        name: "TaskFeedback_Duration",
                        isRequired: true,
                        inputType: "number",
                        min: 0,
                        max: 90,
                        placeholder: "Time in minutes (e.g., 6.5)",
                    },
                    {
                        title: "How would you feel if you had to do the same task again one more time?",
                        name: "TaskFeedback_Repeat",
                        type: "rating",
                        rateType: "smileys",
                        rateMin: -4,
                        rateMax: 4,
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
// Fixation trials - if repeats following premature key presses don't have to be the same duration
const _simpleRT_fixationcross = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: ["ArrowDown"],
    trial_duration: function () {
        return randomInteger(500, 2000)
    },
    save_trial_parameters: {
        trial_duration: true,
    },
    data: {
        screen: "fixation",
    },
    response_ends_trial: true,
}

// The fixation trials are put into a timeline that loops if an early response is detected
const simpleRT_fixationcross = {
    timeline: [_simpleRT_fixationcross],
    loop_function: function (data) {
        if (jsPsych.pluginAPI.compareKeys(data.values()[0].response, null)) {
            return false
        } else {
            return true
        }
    },
}

//
// const fixation = {
//     type: jsPsychHtmlKeyboardResponse,
//     stimulus: '<div style="font-size:60px;">+</div>',
//     choices: ["ArrowDown"],
//     trial_duration: function () {
//         var prev_trial_data = jsPsych.data.get().last(1).values()[0]
//         if (prev_trial_data.premature_response == true){
//             return prev_trial_data.fixation_duration
//         } else {
//             return randomInteger(lower_isi, upper_isi)
//         }
//     },
//     save_trial_parameters: {
//         trial_duration: true
//     },
//     data: {
//         screen: "fixation",
//     },
//     on_start: function (trial) {
//         trial.data.fixation_duration = trial.trial_duration
//     },
//     on_finish: function (data) {
//         data.premature_response = data.response !== null
//     },
//     response_ends_trial: true,
// }

// const fixation_procedure = {
//     timeline: [fixation],
//     loop_function: function (data) {
//         var last_fx_trial = jsPsych.data.get().last(1).values()[0]
//         return last_fx_trial.premature_response
//     },
// }

// RT trials
const simpleRT_trial = {
    type: jsPsychImageKeyboardResponse,
    stimulus: "stimuli/red_square.png",
    choices: ["ArrowDown"],
    trial_duration: 600, // maximum reaction time allowed
    data: {
        screen: "response",
    },
}

// Linking fixation and RT trials
const simpleRT_task = {
    timeline: [simpleRT_fixationcross, simpleRT_trial],
    randomize_order: true,
    repetitions: 3, // number of trials
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
