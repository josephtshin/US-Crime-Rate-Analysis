{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "a54488e1",
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Collecting simpy\n",
      "  Downloading simpy-4.1.1-py3-none-any.whl (27 kB)\n",
      "Installing collected packages: simpy\n",
      "Successfully installed simpy-4.1.1\n"
     ]
    }
   ],
   "source": [
    "!pip install simpy"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9f70b03f",
   "metadata": {},
   "source": [
    "In this problem you, can simulate a simplified airport security system at a busy airport. Passengers arrive\n",
    "according to a Poisson distribution with λ1 = 5 per minute (i.e., mean interarrival rate 1 = 0.2 minutes)\n",
    "to the ID/boarding-pass check queue, where there are several servers who each have exponential service\n",
    "time with mean rate 2 = 0.75 minutes. [Hint: model them as one block that has more than one resource.]\n",
    "After that, the passengers are assigned to the shortest of the several personal-check queues, where they go\n",
    "through the personal scanner (time is uniformly distributed between 0.5 minutes and 1 minute).\n",
    "Use the Arena software (PC users) or Python with SimPy (PC or Mac users) to build a simulation of the\n",
    "system, and then vary the number of ID/boarding-pass checkers and personal-check queues to determine\n",
    "how many are needed to keep average wait times below 15 minutes. [If you’re using SimPy, or if you\n",
    "have access to a non-student version of Arena, you can use λ1 = 50 to simulate a busier airport.]\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "52b46a76",
   "metadata": {},
   "outputs": [],
   "source": [
    "# Importing packages\n",
    "import simpy\n",
    "import random\n",
    "import statistics"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "78200ac4",
   "metadata": {},
   "outputs": [],
   "source": [
    "# These are the simulation parameters I set.\n",
    "random_seed  = 42\n",
    "simulation_time = 10000\n",
    "lambda_arrival = 50\n",
    "mean_id_time = 0.75\n",
    "min_scan_time = 0.5\n",
    "max_scan_time = 1.0"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "434ea26d",
   "metadata": {},
   "outputs": [],
   "source": [
    "def passenger(env, name, id_checkers, scanners):\n",
    "    arrival_time = env.now\n",
    "    \n",
    "    # Wait for ID checker\n",
    "    with id_checkers.request() as request:\n",
    "        yield request\n",
    "        id_start = env.now\n",
    "        yield env.timeout(random.expovariate(1.0 / mean_id_time))\n",
    "    \n",
    "    # Choose the shortest scanner queue\n",
    "    \n",
    "    shortest_queue = min(scanners, key = lambda scanner: len(scanner.queue))\n",
    "    with shortest_queue.request() as request:\n",
    "        yield request\n",
    "        yield env.timeout(random.uniform(min_scan_time, max_scan_time))\n",
    "    \n",
    "    # Record total wait time\n",
    "    \n",
    "    total_wait = env.now - arrival_time\n",
    "    wait_times.append(total_wait)\n",
    "\n",
    "def arrival_process(env, id_checkers, scanners):\n",
    "    i = 0\n",
    "    while True:\n",
    "        yield env.timeout(random.expovariate(lambda_arrival))\n",
    "        i += 1\n",
    "        env.process(passenger(env, f'Passenger {i}', id_checkers, scanners))\n",
    "\n",
    "def run_simulation(n_id_checkers = 5, n_scanners = 5):\n",
    "    global wait_times\n",
    "    random.seed(random_seed)\n",
    "    wait_times = []\n",
    "    \n",
    "    env = simpy.Environment()\n",
    "    id_checkers = simpy.Resource(env, capacity = n_id_checkers)\n",
    "    scanners = [simpy.Resource(env, capacity = 1) for _ in range(n_scanners)]\n",
    "    \n",
    "    env.process(arrival_process(env, id_checkers, scanners))\n",
    "    env.run(until = simulation_time)\n",
    "    \n",
    "    avg_wait = statistics.mean(wait_times)\n",
    "    return avg_wait\n",
    "\n",
    "results = []\n",
    "for id_servers in range(3, 10):\n",
    "    for scanners in range(3, 10):\n",
    "        avg_wait = run_simulation(n_id_checkers = id_servers, n_scanners = scanners)\n",
    "        results.append((id_servers, scanners, avg_wait))\n",
    "        if avg_wait < 15:\n",
    "            print(f\"ID Checkers: {id_servers}, Scanners: {scanners}, Average Wait: {avg_wait: .2f} mins\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.10.11"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
