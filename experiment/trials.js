// Fixation trials
var fixation = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: ['ArrowDown'],
    trial_duration: function(){
        var prev_trial_data = jsPsych.data.get().last(1).values()[0]
        if (prev_trial_data.premature_response == true){
            return prev_trial_data.fixation_duration
        } else {
        var fx_vals = [];
        var n = 0;
        while (lower_isi+n*isi_steps <= upper_isi){
            fx_vals.push(lower_isi+n*isi_steps)
            var n = n + 1
        }
        var trial_isi = jsPsych.randomization.sampleWithoutReplacement(fx_vals, 1)[0];
        return trial_isi
    }
    },
    data: {
        screen: 'fixation',
    },
    on_start: function(trial) {
        trial.data.fixation_duration = trial.trial_duration
    },
    on_finish: function(data){
        data.premature_response = data.response !== null;
    }
};


var fixation_procedure = {
    timeline: [fixation],
    loop_function: function(data) {
        var last_fx_trial = jsPsych.data.get().last(1).values()[0];
        return last_fx_trial.premature_response
    }
};


// RT trials
var test = {
    type: jsPsychImageKeyboardResponse,
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['ArrowDown'],
    trial_duration: max_rt,
    data: {
        screen: 'response',
        correct_response: jsPsych.timelineVariable('correct_response')
    },
    on_finish: function(data){
        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);
    } // too slow -> correct = false
};


// Linking fixation and RT trials
var test_procedure = {
    timeline: [fixation_procedure, test],
    timeline_variables: test_stimuli,
    randomize_order: true, 
    repetitions: n_trials
};