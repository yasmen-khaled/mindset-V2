<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Question;
use App\Models\Option;
use Illuminate\Http\Request;

class QuizController extends Controller
{
    public function getQuestions(Category $category)
    {
        $questions = $category->questions()->with('options')->get();
        
        return response()->json($questions->map(function ($question) {
            return [
                'id' => $question->id,
                'text' => $question->text,
                'options' => $question->options->map(function ($option) {
                    return [
                        'id' => $option->id,
                        'text' => $option->text,
                        'isCorrect' => $option->is_correct
                    ];
                })
            ];
        }));
    }

  public function addQuestion(Request $request, Category $category)
{
    $request->validate([
        'text' => 'required|string',
        'options' => 'required|array|min:2',
        'options.*.text' => 'required|string',
        'options.*.isCorrect' => 'required|boolean',
    ]);

    // Check that exactly one option is correct
    $correctOptions = collect($request->options)->where('isCorrect', true)->count();
    if ($correctOptions !== 1) {
        return response()->json(['error' => 'Exactly one option must be marked as correct'], 422);
    }

    // الحصول على level_id من الـ category
    $levelId = $category->level;

    // إنشاء السؤال مع استخدام level_id المستخرج من category
    $question = $category->questions()->create([
        'text' => $request->text,
        'level_id' => $levelId
    ]);

    foreach ($request->options as $optionData) {
        $question->options()->create([
            'text' => $optionData['text'],
            'is_correct' => $optionData['isCorrect']
        ]);
    }

    return response()->json([
        'message' => 'Question added successfully',
        'question' => $question->load('options')
    ], 201);
}


    public function deleteQuestion(Category $category, Question $question)
    {
        // Ensure the question belongs to the category
        if ($question->category_id !== $category->id) {
            return response()->json(['error' => 'Question not found in this category'], 404);
        }

        $question->delete();
        return response()->json(['message' => 'Question deleted successfully']);
    }

    public function updateQuestion(Request $request, Category $category, Question $question)
    {
        // Ensure the question belongs to the category
        if ($question->category_id !== $category->id) {
            return response()->json(['error' => 'Question not found in this category'], 404);
        }

        $request->validate([
            'text' => 'required|string',
            'options' => 'required|array|min:2',
            'options.*.text' => 'required|string',
            'options.*.isCorrect' => 'required|boolean'
        ]);

        // Check that exactly one option is correct
        $correctOptions = collect($request->options)->where('isCorrect', true)->count();
        if ($correctOptions !== 1) {
            return response()->json(['error' => 'Exactly one option must be marked as correct'], 422);
        }

        // Update question text
        $question->update([
            'text' => $request->text
        ]);

        // Delete existing options and create new ones
        $question->options()->delete();

        foreach ($request->options as $optionData) {
            $question->options()->create([
                'text' => $optionData['text'],
                'is_correct' => $optionData['isCorrect']
            ]);
        }

        return response()->json([
            'message' => 'Question updated successfully',
            'question' => $question->load('options')
        ]);
    }
}
