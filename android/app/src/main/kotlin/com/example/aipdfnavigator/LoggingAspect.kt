package com.example.aipdfnavigator

import android.util.Log
import org.aspectj.lang.JoinPoint
import org.aspectj.lang.annotation.AfterThrowing
import org.aspectj.lang.annotation.Aspect
import org.aspectj.lang.annotation.Before
import org.aspectj.lang.annotation.Pointcut

@Aspect
class LoggingAspect {

    private val TAG = "AOPLog"

    @Pointcut("execution(* android.app.Activity+.on*(..)) || execution(* androidx.fragment.app.Fragment+.on*(..))")
    fun lifecycleMethods() {}

    @Pointcut("execution(* android.view.View.OnClickListener+.onClick(..))")
    fun inputEvents() {}

    @Before("lifecycleMethods()")
    fun logLifecycle(joinPoint: JoinPoint) {
        val className = joinPoint.signature.declaringType.simpleName
        val methodName = joinPoint.signature.name
        Log.d(TAG, "$className -> $methodName : Lifecycle event triggered")
    }

    @Before("inputEvents()")
    fun logInput(joinPoint: JoinPoint) {
        val className = joinPoint.signature.declaringType.simpleName
        val methodName = joinPoint.signature.name
        Log.d(TAG, "$className -> $methodName : User input event triggered")
    }

    @AfterThrowing(pointcut = "execution(* com.example.aipdfnavigator..*(..))", throwing = "error")
    fun logExceptions(joinPoint: JoinPoint, error: Throwable) {
        val className = joinPoint.signature.declaringType.simpleName
        val methodName = joinPoint.signature.name
        Log.e(TAG, "$className -> $methodName : Exception caught - ${error.message}")
    }
}
