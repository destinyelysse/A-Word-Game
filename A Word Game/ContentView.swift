//  ContentView.swift
//  A Word Game
//
//  Created by Destiny Serna on 11/16/20.

import SwiftUI

struct ContentView: View {
    
    @State private var newWord = ""
    @State private var usedWords = [String]()
    @State private var baseWord = "Baseword"
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var wordScore = 0
    @State private var letterScore = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Words: \(wordScore)")
                        .padding()
                    Spacer()
                    Text("Letters: \(letterScore)")
                        .padding()
                    Spacer()
                }
                Text("Use the letters in \(baseWord) to create new words. Guesses that have already been used, match the baseword, or are not real words will not count towards your score.")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.subheadline)
                Text("How many words can you discover?")
                    .font(.headline)
                    
                    .lineLimit(nil)
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            } .navigationBarTitle(baseWord)
            .navigationBarItems(leading: Button("New Game") { startGame()
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Already Used", message: "You have already discovered this word.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not Possible", message: "The word you entered cannot be made from the letters in \(baseWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not Real", message: "The word you entered doesn't seem to be a real word.")
            return
        }
        
        guard isNotBase(word: answer) else {
            wordError(title: "Same as Base", message: "Your word is the base word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        wordScore += 1
        letterScore += answer.count
        
        newWord = ""
        
    }
    
    func startGame() {
        if let wordListURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let wordList = try? String(contentsOf: wordListURL) {
                let gameWords = wordList.components(separatedBy: "\n")
                baseWord = gameWords.randomElement() ?? "Baseword"
                usedWords.removeAll()
                letterScore = 0
                wordScore = 0
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible (word: String) -> Bool {
        var possibleLetters = baseWord
        
        for letter in word {
            if let pos = possibleLetters.firstIndex(of: letter) {
                possibleLetters.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal (word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        let isReal = misspelledRange.location == NSNotFound
        return isReal
    }
    
    func isNotBase (word: String) -> Bool {
        return word != baseWord
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
