// Welcome
var welcome = {
    type: jsPsychHtmlKeyboardResponse, 
    stimulus: "Welcome to the experiment. Press any key to begin."
};

// Instructions
var instructions = {
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
    post_trial_gap: 2000
};


// Debrief
// TO DO : ADD ANY FURTHER DETAILS, E.G., LINK??
var debrief_block = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function(){
        var trials = jsPsych.data.get().filter({screen:'response'});
        var correct_trials = trials.filter({correct: true});
        // var accuracy = Math.round(correct_trials.count()/trials.count()*100);
        var rt = Math.round(correct_trials.select('rt').mean());

        return `
        <p>Your average response time was ${rt}ms.</p>
        <p>Press any key to complete the experiment. Thank you!</p>`
    }
};