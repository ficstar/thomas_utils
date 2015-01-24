# Thomas Utils

Thomas Utils is a gem to provide some basic helper classes to be used with my other projects.

## Installation

Add this line to your application's Gemfile:

    gem 'thomas_utils', git: 'https://github.com/thomasrogers03/thomas_utils.git'

## Current Features

* FutureWrapper: Apply some additional logic to your futures before returning a value. Supports futures implementing #join and #get.
* ObjectStream: Incrementally write object values to a stream, flushing them in groups to a provided block.
* PeriodicFlusher: To be used with ObjectStream; periodically calls #flush on the buffer, running the block on regular intervals.
