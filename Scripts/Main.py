# GET OPTION INPUT
def main_menu():

    while True:
        option = print_menu()

        if(option == 0):
            print("Exiting menu...")
            break
    
        elif option == 1:
            print("Calculating metrics for individual simulations...")
            import CalculateMetrics
        
        elif option == 2:
            print("Joining individual simulations and calculating metrics...")
            import JoinSimulations
        
        else:
            print("Invalid Choice.")

#PRINT MAIN MENU
def print_menu():
    print("What do you want to do?")
    print("-----------------------")
    print("0 - Exit Menu")
    print("1 - Calculate Metrics For Single Simulations")
    print("2 - Join Simulations & Calculate Metrics")
    print("-----------------------")

    choice = int(input())

    return choice

main_menu()