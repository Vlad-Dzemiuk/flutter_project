import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Налаштування JVM версій після того, як всі проекти оцінені та задачі створені
gradle.taskGraph.whenReady {
    allprojects {
        // Налаштування Kotlin для всіх модулів
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        
        // Налаштування Java тільки для не-Android модулів
        // Android модулі мають налаштування через android.compileOptions
        // Не встановлюємо sourceCompatibility/targetCompatibility для Android модулів,
        // щоб не заважати Android Gradle Plugin налаштувати bootclasspath
        if (!project.hasProperty("android")) {
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "17"
                targetCompatibility = "17"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Налаштування Android модулів через afterEvaluate
    afterEvaluate {
        // Для Android модулів налаштування Java версії вже встановлені через android.compileOptions
        // Додатково переконуємося, що Kotlin використовує правильну версію
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        
        // Для Android модулів переконуємося, що compileOptions встановлені правильно
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                // Використовуємо Kotlin DSL для безпечного доступу до compileOptions
                try {
                    val compileOptionsMethod = android.javaClass.methods.find { it.name == "getCompileOptions" || it.name == "compileOptions" }
                    if (compileOptionsMethod != null) {
                        val compileOptions = compileOptionsMethod.invoke(android)
                        val setSourceMethod = compileOptions.javaClass.methods.find { it.name == "setSourceCompatibility" }
                        val setTargetMethod = compileOptions.javaClass.methods.find { it.name == "setTargetCompatibility" }
                        if (setSourceMethod != null && setTargetMethod != null) {
                            setSourceMethod.invoke(compileOptions, JavaVersion.VERSION_17)
                            setTargetMethod.invoke(compileOptions, JavaVersion.VERSION_17)
                        }
                    }
                } catch (e: Exception) {
                    // Якщо не вдалося встановити через reflection, залишаємо як є
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
