const doggoNogo_instructions = {
    type: jsPsychSurvey,
    survey_json: {
        showQuestionNumbers: false,
        completeText: "I've finished the game and I'm ready to continue the experiment",
        pages: [
            {
                elements: [
                    {
                        type: "html",
                        name: "Doggo Nogo",
                        html: `
    <p align='center'>The link below will direct you to the <strong>add var specifying 'first' or 'second' depending on their order</strong> part of the experiment.</p>
    <p align='center'>In this experiment, your challenge is to help Doggo get as many bones as possible.</p>
    <p align='center'>Whenever a bone appears,
    press the <strong>Down Arrow</strong> as fast as you can.</p>
    <p align='center'><img src="stimuli/bone.png" height=${window.innerHeight/6} align='center'/><img src="stimuli/doggos1b.png" height=${window.innerHeight/4} align='center'/></p>
    <p align='center'>Click <a href="https://sussex-psychology-software-team.github.io/DoggoNogo/?datapipe=AlXXHjfLwVP3&p=${participantID}&s=DoggoNogoValidation&l1n=60"><strong style="color:blue">here</strong></a>
     to go to the experiment.</p><br><br><br>
    `,
                    },
                ],
            },
        ],
        data: {
            screen: "doggoNogo_instructions"
        }
    },
    on_load: function() {
        function hideButton() {
            const doggoNogoNext = document.querySelector('.jspsych-nav-complete');
            
            if (doggoNogoNext) {
                doggoNogoNext.style.display = "none";

                setTimeout(function() {
                    doggoNogoNext.style.display = "inline-block";
                }, 1200); // set to ~120000 ms? (2mins)
            } else {
                requestAnimationFrame(hideButton);
            }
        }
        hideButton();
    }
};
