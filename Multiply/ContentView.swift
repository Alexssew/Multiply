//
//  ContentView.swift
//  Multiply
//
//  Created by Alex on 14/03/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var questions = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].shuffled()
    @State var textFieldAnswer:Int = 0
    @State var newNumber = 0
    @State var score = 0
    @State var questionsCount = 0
    
    @State var nextScreen:Bool = false
    
    let layout = [GridItem(.adaptive(minimum: 100, maximum: 150))]
    
    var body: some View {
        NavigationView {
            ZStack{
                
                ScrollView(showsIndicators: false){
                    
                    LazyVGrid(columns: layout) {
                        
                        ForEach(0..<11) { number in
                                Button {
                                    //
                                    newNumber = number + 2
                                    nextScreen.toggle()
                                } label: {
                                    Text("\(number + 2) X ...")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 100)
                                        .padding()
                                        .background(.purple)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }
//
                        }
                        
                    }.padding()
                }
                
            }.navigationTitle("Multiply  ✖️ 🔖 ⭐️")
                .fullScreenCover(isPresented: $nextScreen){
                    withAnimation(.spring()) {
                        QstnSelectionView(newNumber: $newNumber, questions: $questions, score: $score, questionsCount: $questionsCount)
                    }
                }
            
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
        // QstnSelectionView()
        
    }
}

struct QstnSelectionView: View {
  
    @Binding var newNumber:Int
    @Binding var questions:[Int]
    @Binding var score:Int
    @Binding var questionsCount:Int
    
    @State var stepperValue = 5
    @State var questionsScreen:Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("How many questions do you want to try out? 💪🏼")
                    HStack {
                        Text("\(stepperValue)")
                            .font(.headline)
                            .frame(width: 30, height: 30)
                            .background(.pink)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                        
                        Stepper("Number of Questions  \(stepperValue)", value: $stepperValue, in: 5...20, step: 5)
                            .padding()
                            .labelsHidden()
                    }
                    
                    Button {
                        questionsScreen.toggle()
                    } label: {
                        Text("Ready? Continue")
                            .font(.headline)
                            .frame(width: 200, height: 50)
                            .background(.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    
                }.padding()
                
            }.fullScreenCover(isPresented: $questionsScreen) {
                QuestionsView(newNumber: $newNumber, questions: $questions, score: $score, questionsCount: $questionsCount, stepperValue: $stepperValue)
            }
        }
        
    }
}

struct QuestionsView: View {
    
    @Binding var newNumber:Int
    @Binding var questions:[Int]
    @Binding var score:Int
    @Binding var questionsCount:Int
    @Binding var stepperValue:Int
    
    @State var textFieldText = ""
    @State var textFieldAnswer = 0
    @State var showAlert:Bool = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var gameOver = false
    
    @State var animate = false
    private let animation = Animation.interpolatingSpring(mass: 5, stiffness: 0.5, damping: 1, initialVelocity: 3) .repeatForever(autoreverses: true)
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                VStack {
                    Text("Question Number  \(questionsCount + 1)")
                    Text("Your score is \(score)")
                        .font(.headline)
                        .frame(height: 55)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .background(.pink)
                        .cornerRadius(20)
                    
                    Spacer()
                    Text("What is \(newNumber) X \(questions[0]) ?")
                        .font(.headline.bold())
                    TextField("The answer is ...", text: $textFieldText)
                        .padding(50)
                        .frame(height: 55)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                        .keyboardType(.numbersAndPunctuation)
                        .onSubmit {
                            if itsAnInt(){
                                calculateResult(newNumber)
                            }
                        }
                    Spacer()
                    Spacer()
                }.padding(.horizontal, 20)
                 .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel(Text(questionsCount == stepperValue ? "Play Again" : "Next Question"), action: {questionsCount == stepperValue ? theLastQuestion() : nextQuestion()
                        }))
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                theLastQuestion()
                            } label: {
                                Image(systemName: "x.circle")
                                    .padding()
                                    .foregroundColor(.red)
                            }
                            
                        }
                    }
            }
            .fullScreenCover(isPresented: $gameOver) {
                ContentView()
                    .transition(AnyTransition.opacity.animation(.easeIn))
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    HStack(spacing: 100) {
                        Spacer()

                        Text("🙇 🧐 💬 ✨")
                            .offset(x: animate ? -1 :  0.5, y: animate ? 1 : -0.5)
                            .font(animate ? .largeTitle : .headline)
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0)
                            .onAppear(perform: {
                                    withAnimation(animation) {
                                        self.animate.toggle()
                                    }
                                })
                    }
                    
                }
            }
        }
    }
    
    func calculateResult(_ number:Int) {
        self.newNumber = number
        questionsCount += 1
        self.stepperValue = stepperValue
        let numberFromArray = questions[0]
        textFieldAnswer = Int(textFieldText) ?? 0
        
        if newNumber * numberFromArray == textFieldAnswer {
            score += 1
            alertTitle = "Good ⭐️"
            alertMessage = "Current score is: \(score)"
        }else{
            alertTitle = "Oops! Sorry!"
            alertMessage = "Lets go.. bounce back strong"
        }
        if questionsCount == stepperValue {
            //game over
            alertTitle = "Game Over 🚨"
            if score == questionsCount {
                alertMessage = "Brilliant🎖⭐️ \(score) out of \(questionsCount)"
            } else{
                alertMessage = "Final Score Is \(score) out of \(questionsCount)"
            }
            
            
        }
        showAlert.toggle()
        
    }

    func itsAnInt () -> Bool{
        let intValue = textFieldAnswer
        if intValue * 0 == 0 {
            return true
        }else {
            return false
        }
    }
    func nextQuestion(){
        questions.shuffle()
        self.newNumber = newNumber
    }
    func theLastQuestion(){ //to restart the game
        gameOver = true
        
    }
    
}

