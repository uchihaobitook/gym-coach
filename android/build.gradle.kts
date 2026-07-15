allprojects {
    repositories {
        google()
        mavenCentral()
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
}

subprojects {
    project.evaluationDependsOn(":app")
}

fun Project.forceCompileSdk36() {
    val android = extensions.findByName("android") ?: return
    try {
        android.javaClass
            .getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
            .invoke(android, 36)
    } catch (_: Throwable) {
        try {
            android.javaClass
                .getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                .invoke(android, 36)
        } catch (_: Throwable) {
            // ignore non-android modules
        }
    }
}

subprojects {
    if (state.executed) {
        forceCompileSdk36()
    } else {
        afterEvaluate { forceCompileSdk36() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
