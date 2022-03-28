function []=plot_EDF(M_max,x_max,y_max,nodes)
% ********** By Magnus Jonsson ***********
%
% Scheduling simulation of a single-switch network, with RT-channels having some
% simplified assumptions like deadline equal to period, deadline equally divided between the hops,
% and delay constants already subtracted from the delay bound.
% Plots 'Acceptence ratio [%]' against 'Number of requested channels'
%
% Example of command with parameters to run (copy to the Matlab Command Window):
% plot_EDF(200,200,102,20)
%
% M_max    = plot x-axis to M_max inclusive (Number of generated channels)
% x_max    = x-axis end
% y_max    = y-axis end
% nodes     = number of nodes

% Define some constants (may be changed to variables later on)
% Times are, for example, given in terms of 125 us (only as an assumption)
period=40; % 5 ms at 125us frames
capacity=4; % 500 us at 125us frames
k_max=10; % Number of runs to get smother curves (average statistics over several runs)

% Reset matrix for storage of data for the average statistics over several runs
total_num_of_acc=zeros(1,M_max);

% Run the simulation below a number of times to get god average statistics
for k=1:k_max,

    % Generate requests for RT channels
    for i=1:M_max,
      RTC_source(i)=1+floor(nodes*rand*0.999999);
      RTC_dest(i)=1+floor(nodes*rand*0.999999);
      RTC_period(i)=period;
      RTC_deadline(i)=period;
      RTC_capacity(i)=capacity;
      RTC_d1(i)=RTC_deadline(i)/2;
      RTC_d2(i)=RTC_deadline(i)/2;
    end

    % Reset matrix for storage of results for this simulation
    num_of_acc=zeros(1,M_max);

    %reset load matrix where (1,i) is the link from node i to the switch and (2,i) is from the switch
    link_load=zeros(2,nodes);

    % Check for schedability
    for i=1:M_max,

      % check next RT channel
      if (link_load(1,RTC_source(i)) + RTC_capacity(i)/RTC_d1(i) <= 1) & (link_load(2,RTC_dest(i)) + RTC_capacity(i)/RTC_d2(i) <= 1),

        % add load to existing load for link1 and link2
        link_load(1,RTC_source(i)) = link_load(1,RTC_source(i)) + RTC_capacity(i)/RTC_d1(i);
        link_load(2,RTC_dest(i)) = link_load(2,RTC_dest(i)) + RTC_capacity(i)/RTC_d2(i);

        % Increment number of accepted channels
        for j=i:M_max,
          num_of_acc(j)=num_of_acc(j)+1;
        end

        % Also, increment number of accepted channels to matrix for average of several simulations
        for j=i:M_max,
          total_num_of_acc(j)=total_num_of_acc(j)+1;
        end

      end
    end
end

% Prepare for plotting
for i=1:M_max,
  X(i)=i;
  total_num_of_acc(i)=100*total_num_of_acc(i)/(i*k_max);
end

figure;
%whitebg;
axis([0 x_max 0 y_max]);
xlabel('Number of requested channels');
ylabel('Acceptence ratio [%]');

hold on;
for i=1:1,
  if i==1,
    plot(X(:),total_num_of_acc(:),'k-',X(:),total_num_of_acc(:),'ko');
  end
  if i==2,
    plot(A(1,:),A(2,:),'k-',A(1,:),A(2,:),'k+');
  end
  if i==3,
    plot(A(1,:),A(2,:),'k-',A(1,:),A(2,:),'k*');
  end
  if i==4,
    plot(A(1,:),A(2,:),'k-',A(1,:),A(2,:),'kx');
  end
  hold on;
end



