<?php

namespace App\Http\Controllers;

use App\Http\Requests\SaveExpenseRequest;
use App\Models\Expense;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;

class ExpenseController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): JsonResponse
    {
        $expenses = Expense::latest()->get();

        return response()->json($expenses, Response::HTTP_OK);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(SaveExpenseRequest $request): JsonResponse
    {
        // Subir la imagen a S3 si está presente
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('expenses', 's3');

            // Hacer que la imagen sea pública (opcional)
            Storage::disk('s3')->setVisibility($imagePath, 'public');

            // Obtener la URL pública de la imagen
            $imageUrl = Storage::disk('s3')->url($imagePath);
        }

        // Crear el registro de gasto en la base de datos
        $expense = Expense::create(array_merge(
            $request->validated(),
            ['image_url' => $imageUrl ?? null]
        ));

        return response()->json($expense, Response::HTTP_CREATED);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);

        return response()->json($expense, Response::HTTP_OK);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(SaveExpenseRequest $request, string $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);

        // Subir una nueva imagen a S3 si está presente
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('expenses', 's3');

            // Hacer que la imagen sea pública (opcional)
            Storage::disk('s3')->setVisibility($imagePath, 'public');

            // Obtener la URL pública de la imagen
            $imageUrl = Storage::disk('s3')->url($imagePath);

            // Eliminar la imagen anterior de S3 (opcional)
            if ($expense->image_url) {
                Storage::disk('s3')->delete(parse_url($expense->image_url, PHP_URL_PATH));
            }
        }

        $expense->update(array_merge(
            $request->validated(),
            ['image_url' => $imageUrl ?? $expense->image_url]
        ));

        return response()->json($expense, Response::HTTP_OK);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);

        // Eliminar la imagen de S3 si existe
        if ($expense->image_url) {
            Storage::disk('s3')->delete(parse_url($expense->image_url, PHP_URL_PATH));
        }

        $expense->delete();

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
