module GymHelper
  # [:now, reset] when the section is reset this week, [:next, reset] when it has the next reset
  # after this week, otherwise nil. Expects @resets_this_week and @next_reset from GymController#show.
  def reset_status(section)
    if (reset = @resets_this_week[section.id])
      [ :now, reset ]
    elsif @next_reset&.wall_section_id == section.id
      [ :next, @next_reset ]
    end
  end

  def reset_note(status, reset)
    label = status == :now ? "New this week!" : "Last chance! Next reset"
    "#{label} · #{l(reset.reset_on, format: "%a %-d %b")}"
  end
end
