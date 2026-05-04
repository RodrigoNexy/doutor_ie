<?php

namespace App\Http\Controllers\Api;

use App\Contracts\Auth\AuthServiceInterface;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginUserRequest;
use App\Http\Requests\Auth\RegisterUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class AuthController extends Controller
{
    public function __construct(
        private readonly AuthServiceInterface $authService,
    ) {}

    public function register(RegisterUserRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $result = $this->authService->register(
            $validated['name'],
            $validated['email'],
            $validated['password'],
        );

        return response()->json([
            'token' => $result->plainTextToken,
            'token_type' => 'Bearer',
            'user' => new UserResource($result->user),
        ], Response::HTTP_CREATED);
    }

    public function login(LoginUserRequest $request): JsonResponse
    {
        $validated = $request->validated();

        try {
            $result = $this->authService->login(
                $validated['email'],
                $validated['password'],
            );
        } catch (AuthenticationException) {
            return response()->json([
                'message' => __('auth.failed'),
            ], Response::HTTP_UNAUTHORIZED);
        }

        return response()->json([
            'token' => $result->plainTextToken,
            'token_type' => 'Bearer',
            'user' => new UserResource($result->user),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $this->authService->logout($user);

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
