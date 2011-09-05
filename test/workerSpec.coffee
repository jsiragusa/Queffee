describe 'Worker', ->
  describe '#start', ->

    nullJob = (priority_ = 1) ->
      {
        perform: (callback) -> callback()
        priority: -> priority_
      }

    it 'performs the first job', ->
      job = nullJob()
      spyOn(job, 'perform')
      q = new quefee.Q([job])
      new quefee.Worker(q).start()
      expect(job.perform).toHaveBeenCalled()

    it 'goes to the next job when the current job is done', ->
      job1 = nullJob(2)
      job2 = nullJob(1)
      spyOn(job2, 'perform')

      q = new quefee.Q([job1, job2])
      new quefee.Worker(q).start()
      expect(job2.perform).toHaveBeenCalled()

    it 'calls onIdle once all jobs are done', ->
      done = false
      q = new quefee.Q([nullJob(1)])
      new quefee.Worker(q, (-> done = true)).start()
      expect(done).toBeTruthy()

    describe "#picking up newly inserted jobs", ->
      it 'automatically picks up the newly added job when idle', ->
        job1 = nullJob(2)
        job2 = nullJob(1)
        spyOn(job2, 'perform')
        q = new quefee.Q([job1])
        new quefee.Worker(q).start()
        q.enqueue(job2)
        expect(job2.perform).toHaveBeenCalled()

      it 'does not automatically picks up the newly added job if is running a job', ->
        job1 = {
            perform: (callback) -> @done = callback
            priority: -> 1
          }
        job2 = nullJob()
        spyOn(job2, 'perform')
        q = new quefee.Q([job1])
        new quefee.Worker(q).start()
        q.enqueue(job2)
        expect(job2.perform).not.toHaveBeenCalled()
        job1.done()
        expect(job2.perform).toHaveBeenCalled()




