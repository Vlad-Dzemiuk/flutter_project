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
// Використовуємо whenReady, щоб застосувати налаштування після того, як AGP вже налаштував bootclasspath
gradle.taskGraph.whenReady {
    allprojects {
        // Налаштування Kotlin для всіх модулів
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }

        // Налаштування Java для всіх модулів (включаючи Android)
        // На цей момент AGP вже налаштував bootclasspath, тому це не заважає
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
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
        // Для всіх модулів (включаючи Android) встановлюємо Kotlin JVM target 17
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }

        // Для Android модулів встановлюємо Java 17 через android.compileOptions
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val compileOptionsMethod = android.javaClass.methods.find {
                        it.name == "getCompileOptions" || it.name == "compileOptions"
                    }
                    if (compileOptionsMethod != null) {
                        val compileOptions = compileOptionsMethod.invoke(android)
                        val setSourceMethod = compileOptions.javaClass.methods.find {
                            it.name == "setSourceCompatibility"
                        }
                        val setTargetMethod = compileOptions.javaClass.methods.find {
                            it.name == "setTargetCompatibility"
                        }
                        if (setSourceMethod != null && setTargetMethod != null) {
                            setSourceMethod.invoke(compileOptions, JavaVersion.VERSION_17)
                            setTargetMethod.invoke(compileOptions, JavaVersion.VERSION_17)
                        }
                    }
                } catch (e: Exception) {
                    // Якщо reflection не спрацював, застосовуємо через tasks
                    tasks.withType<JavaCompile>().configureEach {
                        sourceCompatibility = "17"
                        targetCompatibility = "17"
                    }
                }
            } else {
                // Якщо не вдалося отримати android extension, застосовуємо через tasks
                tasks.withType<JavaCompile>().configureEach {
                    sourceCompatibility = "17"
                    targetCompatibility = "17"
                }
            }
        } else {
            // Для НЕ-Android модулів встановлюємо Java 17
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "17"
                targetCompatibility = "17"
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
