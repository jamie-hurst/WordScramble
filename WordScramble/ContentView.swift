//
//  ContentView.swift
//  WordScramble
//
//  Created by Jameson Hurst on 10/29/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var roundScore = 0
    @State private var totalScore = 0
   
    
    
    
    var body: some View {
        
        NavigationView {
            List {
                
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            // the SF symbol reflects the number of points earned per word.
                            Image(systemName: "\(word.count - 2).circle")
                            Text(word)
                        }
                        
                    }
                }
                
                Section {
                    Text("Your score for the current word is \(roundScore)")
                }
                
                Section {
                    Text("Your total score is \(totalScore)")
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Word", action: startGame)
            }
        }
        
        
    }
    
    func addNewWord() {
        let wordScore: Int
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // validation
        
        guard answer.count > 2 else {
            wordError(title: "Word is not long enough", message: "Please make sure the word is at least 3 letters long.")
            return }
        
        guard answer != rootWord else {
            wordError(title: "Word is the prompt", message: "You need to build words from this word; try again.")
            return }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Hmmm, you sure that's a valid English word?")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try again. This word was already used.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "\(rootWord) doesn't contain those letters.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        
        wordScore = answer.count - 2
        
        roundScore = roundScore + wordScore
        totalScore = totalScore + wordScore
    }
    
    
    func startGame() {
        usedWords = [String]()
        newWord = ""
        roundScore = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
