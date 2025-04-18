document.addEventListener 'DOMContentLoaded', ->
    elementCountInput = document.getElementById('elementCount')
    runBenchmarkButton = document.getElementById('runBenchmark')
    resultsDiv = document.getElementById('results')
    benchmarkChartCanvas = document.getElementById('benchmarkChart')
    testRepetitionsInput = document.getElementById('testRepetitions')
    testRepetitionsValue = document.getElementById('testRepetitionsValue')
    ctx = benchmarkChartCanvas.getContext('2d')

    chart = null

    testRepetitionsInput.addEventListener 'input', ->
        testRepetitionsValue.textContent = testRepetitionsInput.value

    runBenchmark = (elementCount) ->
        new Promise (resolve) ->
            startTime = performance.now()
            container = document.createElement('div')
            for i in [0...elementCount]
                element = document.createElement('div')
                element.textContent = "Element #{i + 1}"
                container.appendChild(element)
            document.body.appendChild(container)
            endTime = performance.now()

            duration = endTime - startTime
            document.body.removeChild(container)
            resolve(duration)

    createBarChart = (data, labels) ->
        maxValue = Math.max data...
        chartHeight = benchmarkChartCanvas.height
        chartWidth = benchmarkChartCanvas.width
        barWidth = chartWidth / labels.length
        padding = 10

        ctx.clearRect(0, 0, chartWidth, chartHeight)

        data.forEach (value, index) ->
            barHeight = (value / maxValue) * (chartHeight - 2 * padding)
            x = index * barWidth
            y = chartHeight - barHeight - padding

            ctx.fillStyle = 'rgba(255, 99, 132, 0.2)'
            ctx.fillRect(x, y, barWidth - 5, barHeight)

            ctx.fillStyle = 'rgba(255, 99, 132, 1)'
            ctx.strokeRect(x, y, barWidth - 5, barHeight)

            ctx.fillStyle = 'black'
            ctx.font = '12px sans-serif'
            ctx.textAlign = 'center'
            ctx.fillText(labels[index], x + barWidth / 2, chartHeight - padding / 2)

    runBenchmarkButton.addEventListener 'click', ->
        elementCount = parseInt(elementCountInput.value)
        repetitions = parseInt(testRepetitionsInput.value)

        if isNaN(elementCount) or elementCount <= 0
            resultsDiv.textContent = 'Please enter a valid number of elements.'
            return

        durations = []
        
        # CoffeeScript async pattern
        (->
            for i in [0...repetitions]
                duration = await runBenchmark(elementCount)
                durations.push(duration)
                resultsDiv.textContent = "Run #{i + 1}: #{duration.toFixed(2)} ms"
                await new Promise (resolve) -> setTimeout(resolve, 50)

            averageDuration = durations.reduce(((a, b) -> a + b), 0) / repetitions
            resultsDiv.textContent = "Average time: #{averageDuration.toFixed(2)} ms"

            labels = Array.from {length: repetitions}, (_, i) -> "Run #{i + 1}"
            labels.push('Average')

            createBarChart([...durations, averageDuration], labels)
        )()
