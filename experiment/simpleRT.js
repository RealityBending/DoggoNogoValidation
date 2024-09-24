// Math utilities =================================================================================
function randomInteger(min = 1, max = 10) {
    return Math.round(Math.random() * (max - min) + min)
}

// Experiment =====================================================================================
// Fixation trials
const FixationCross = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<div style="font-size:80px;">+</div>',
    choices: ["ArrowDown"],
    trial_duration: function () {
        return 2000 // randomInteger(600, 1100)
    },
    save_trial_parameters: {
        trial_duration: true,
    },
    data: {
        screen: "SimpleRT_FixationCross",
    },
    response_ends_trial: true,
}

// Early response conditionally looping timeline
const TimelineFixationCross = {
    timeline: [FixationCross],
    loop_function: function (data) {
        // If no response (good trial), don't repeat
        if (jsPsych.pluginAPI.compareKeys(data.values()[0].response, null)) {
            return false
        } else {
            return true
        }
    },
}

const Stimulus = {
    type: jsPsychImageKeyboardResponse,
    stimulus: "stimuli/red_square.png",
    choices: ["ArrowDown"],
    trial_duration: 5000, // Max RT
    response_ends_trial: true,
    data: {
        screen: "SimpleRT_Stimulus",
    },
    on_finish: function (data) {
        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response)
    }, // too slow -> correct = false
}

// Main timeline
const SimpleRT = {
    timeline: [TimelineFixationCross, Stimulus],
    randomize_order: true,
    repetitions: 3,
}
