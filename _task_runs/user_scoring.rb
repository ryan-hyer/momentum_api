require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Doug_Greig',            # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Mike_Ehlers KM_Admin
    target_groups:          %w(trust_level_1),          # Mods GreatX BraveHearts  trust_level_0 trust_level_1
    ownership_groups:       %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user_scores: {
        update_type:        'newly_voted',                # have_voted, not_voted, newly_voted, all
        target_post:        30719,                      # 28649
        # target_polls:      %w(poll),                  # default is 'poll'
        poll_url:           'https://discourse.gomomentum.org/t/what-s-your-score/7104',
        messages_from:      'Kim_Miller',
        excludes:            %w(Mike_Ehlers)  # Mike_Ehlers
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary

# Jun 22, 2019
# /bin/bash -c "env RBENV_VERSION=2.5.3 /usr/local/bin/rbenv exec ruby /Users/kimardenmiller/Dropbox/l_Spiritual/Momentum/Code/momentum_api/task_single_runs/user_scoring.rb"
# Al_Dorji           has not voted yet
#   Message From:    Kim_Miller           Al_Dorji             What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Al_Dorji             whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Alfonso_Benavides  has not voted yet
#   Message From:    Kim_Miller           Alfonso_Benavides    What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Alfonso_Benavides    whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Andrew_M_Webster   has not voted yet
#   Message From:    Kim_Miller           Andrew_M_Webster     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Andrew_M_Webster     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Andrew_Webster     has not voted yet
#   Message From:    Kim_Miller           Andrew_Webster       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Andrew_Webster       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Anshu_Sanghi       has not voted yet
#   Message From:    Kim_Miller           Anshu_Sanghi         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Anshu_Sanghi         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Antonio_Martinez   has not voted yet
#   Message From:    Kim_Miller           Antonio_Martinez     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Antonio_Martinez     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Art_Muir           has not voted yet
#   Message From:    Kim_Miller           Art_Muir             What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Art_Muir             whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Barry_Finkelstein  has not voted yet
#   Message From:    Kim_Miller           Barry_Finkelstein    What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Barry_Finkelstein    whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Benjamin_Berman    has not voted yet
#   Message From:    Kim_Miller           Benjamin_Berman      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Benjamin_Berman      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bill_Herndon       has not voted yet
#   Message From:    Kim_Miller           Bill_Herndon         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bill_Herndon         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bill_Sprague       has not voted yet
#   Message From:    Kim_Miller           Bill_Sprague         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bill_Sprague         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bill_Zabor         has not voted yet
#   Message From:    Kim_Miller           Bill_Zabor           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bill_Zabor           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bob_Richards       has not voted yet
#   Message From:    Kim_Miller           Bob_Richards         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bob_Richards         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bob_Silver         has not voted yet
#   Message From:    Kim_Miller           Bob_Silver           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bob_Silver           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bo_Zhou            has not voted yet
#   Message From:    Kim_Miller           Bo_Zhou              What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bo_Zhou              whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Brad_Milliken      has not voted yet
#   Message From:    Kim_Miller           Brad_Milliken        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Brad_Milliken        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Brad_Peppard       has not voted yet
#   Message From:    Kim_Miller           Brad_Peppard         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Brad_Peppard         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bran_Scott         has not voted yet
#   Message From:    Kim_Miller           Bran_Scott           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bran_Scott           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Brian_Ruthruff     has not voted yet
#   Message From:    Kim_Miller           Brian_Ruthruff       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Brian_Ruthruff       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Bruce_Scheer       has not voted yet
#   Message From:    Kim_Miller           Bruce_Scheer         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Bruce_Scheer         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Butch_Dority       has not voted yet
#   Message From:    Kim_Miller           Butch_Dority         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Butch_Dority         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Charlie_Bedard     has not voted yet
#   Message From:    Kim_Miller           Charlie_Bedard       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Charlie_Bedard       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Charlie_Ohanlon    has not voted yet
#   Message From:    Kim_Miller           Charlie_Ohanlon      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Charlie_Ohanlon      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Chris_Edgar        has not voted yet
#   Message From:    Kim_Miller           Chris_Edgar          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Chris_Edgar          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Chris_Reed         has not voted yet
#   Message From:    Kim_Miller           Chris_Reed           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Chris_Reed           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Chris_Steck        has not voted yet
#   Message From:    Kim_Miller           Chris_Steck          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Chris_Steck          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Chris_Sulek        has not voted yet
#   Message From:    Kim_Miller           Chris_Sulek          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Chris_Sulek          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Christian_Agardi   has not voted yet
#   Message From:    Kim_Miller           Christian_Agardi     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Christian_Agardi     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Clark_Zhang        has not voted yet
#   Message From:    Kim_Miller           Clark_Zhang          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Clark_Zhang          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Clay_Campbell      has not voted yet
#   Message From:    Kim_Miller           Clay_Campbell        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Clay_Campbell        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Cory_Harasha       has not voted yet
#   Message From:    Kim_Miller           Cory_Harasha         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Cory_Harasha         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Curt_Haynes        has not voted yet
#   Message From:    Kim_Miller           Curt_Haynes          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Curt_Haynes          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Curt_Weil          has not voted yet
#   Message From:    Kim_Miller           Curt_Weil            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Curt_Weil            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dainuri            has not voted yet
#   Message From:    Kim_Miller           Dainuri              What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dainuri              whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dan_Ollendorff     has not voted yet
#   Message From:    Kim_Miller           Dan_Ollendorff       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dan_Ollendorff       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dave_Lloyd         has not voted yet
#   Message From:    Kim_Miller           Dave_Lloyd           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dave_Lloyd           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dave_Mahal         has not voted yet
#   Message From:    Kim_Miller           Dave_Mahal           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dave_Mahal           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dave_Mussoff       has not voted yet
#   Message From:    Kim_Miller           Dave_Mussoff         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dave_Mussoff         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dave_Strigler      has not voted yet
#   Message From:    Kim_Miller           Dave_Strigler        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dave_Strigler        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# David_Coleman      has not voted yet
#   Message From:    Kim_Miller           David_Coleman        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           David_Coleman        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# David_Hohl         has not voted yet
#   Message From:    Kim_Miller           David_Hohl           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           David_Hohl           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# David_Kirk         has not voted yet
#   Message From:    Kim_Miller           David_Kirk           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           David_Kirk           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# David_Mock         has not voted yet
#   Message From:    Kim_Miller           David_Mock           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           David_Mock           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# David_Montagna     has not voted yet
#   Message From:    Kim_Miller           David_Montagna       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           David_Montagna       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dennis_Adsit       has not voted yet
#   Message From:    Kim_Miller           Dennis_Adsit         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dennis_Adsit         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Dennis_Sorensen    has not voted yet
#   Message From:    Kim_Miller           Dennis_Sorensen      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Dennis_Sorensen      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Deven_Kalra        has not voted yet
#   Message From:    Kim_Miller           Deven_Kalra          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Deven_Kalra          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Don_Morgan         has not voted yet
#   Message From:    Kim_Miller           Don_Morgan           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Don_Morgan           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Doug_Greig         has not voted yet
#   Message From:    Kim_Miller           Doug_Greig           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Doug_Greig           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Eamon_Rooney       has not voted yet
#   Message From:    Kim_Miller           Eamon_Rooney         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Eamon_Rooney         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Edmond_Cote        has not voted yet
#   Message From:    Kim_Miller           Edmond_Cote          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Edmond_Cote          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# EO_Rojas           has not voted yet
#   Message From:    Kim_Miller           EO_Rojas             What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           EO_Rojas             whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Eric_Nitzberg      has not voted yet
#   Message From:    Kim_Miller           Eric_Nitzberg        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Eric_Nitzberg        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Flint_Thorne       has not voted yet
#   Message From:    Kim_Miller           Flint_Thorne         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Flint_Thorne         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Francis_daCosta    has not voted yet
#   Message From:    Kim_Miller           Francis_daCosta      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Francis_daCosta      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Garry_Cheney       has not voted yet
#   Message From:    Kim_Miller           Garry_Cheney         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Garry_Cheney         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Gary_Koerzendorfer has not voted yet
#   Message From:    Kim_Miller           Gary_Koerzendorfer   What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Gary_Koerzendorfer   whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Gary_Kraemer       has not voted yet
#   Message From:    Kim_Miller           Gary_Kraemer         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Gary_Kraemer         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Gary_Merrick       has not voted yet
#   Message From:    Kim_Miller           Gary_Merrick         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Gary_Merrick         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Gary_Plep          has not voted yet
#   Message From:    Kim_Miller           Gary_Plep            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Gary_Plep            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Gene_Sussli        has not voted yet
#   Message From:    Kim_Miller           Gene_Sussli          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Gene_Sussli          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Geoff_Wright       has not voted yet
#   Message From:    Kim_Miller           Geoff_Wright         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Geoff_Wright         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Graham_Howe        has not voted yet
#   Message From:    Kim_Miller           Graham_Howe          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Graham_Howe          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Greg_Thayer        has not voted yet
#   Message From:    Kim_Miller           Greg_Thayer          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Greg_Thayer          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Howard_Bailey      has not voted yet
#   Message From:    Kim_Miller           Howard_Bailey        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Howard_Bailey        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# How_Shaw           has not voted yet
#   Message From:    Kim_Miller           How_Shaw             What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           How_Shaw             whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ian_Wilkes         has not voted yet
#   Message From:    Kim_Miller           Ian_Wilkes           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ian_Wilkes           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jack_McInerney     has not voted yet
#   Message From:    Kim_Miller           Jack_McInerney       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jack_McInerney       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jack_Shannon       has not voted yet
#   Message From:    Kim_Miller           Jack_Shannon         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jack_Shannon         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# James_Fitzgerald   has not voted yet
#   Message From:    Kim_Miller           James_Fitzgerald     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           James_Fitzgerald     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# James_Grubinskas   has not voted yet
#   Message From:    Kim_Miller           James_Grubinskas     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           James_Grubinskas     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# James_McKeefery    has not voted yet
#   Message From:    Kim_Miller           James_McKeefery      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           James_McKeefery      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Janos_Keresztes    has not voted yet
#   Message From:    Kim_Miller           Janos_Keresztes      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Janos_Keresztes      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jay_Larrick        has not voted yet
#   Message From:    Kim_Miller           Jay_Larrick          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jay_Larrick          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jeff_Cintas        has not voted yet
#   Message From:    Kim_Miller           Jeff_Cintas          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jeff_Cintas          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jeff_Colvin        has not voted yet
#   Message From:    Kim_Miller           Jeff_Colvin          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jeff_Colvin          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jeff_Klay          has not voted yet
#   Message From:    Kim_Miller           Jeff_Klay            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jeff_Klay            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jerry_Raitzer      has not voted yet
#   Message From:    Kim_Miller           Jerry_Raitzer        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jerry_Raitzer        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jerry_Strebig      has not voted yet
#   Message From:    Kim_Miller           Jerry_Strebig        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jerry_Strebig        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jim_Charley        has not voted yet
#   Message From:    Kim_Miller           Jim_Charley          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jim_Charley          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jim_Georgiou       has not voted yet
#   Message From:    Kim_Miller           Jim_Georgiou         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jim_Georgiou         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jim_Knapp          has not voted yet
#   Message From:    Kim_Miller           Jim_Knapp            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jim_Knapp            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Jim_Leney          has not voted yet
#   Message From:    Kim_Miller           Jim_Leney            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Jim_Leney            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Joe_Sabolefski     has not voted yet
#   Message From:    Kim_Miller           Joe_Sabolefski       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Joe_Sabolefski       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Bodeau        has not voted yet
#   Message From:    Kim_Miller           John_Bodeau          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Bodeau          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Butler        has not voted yet
#   Message From:    Kim_Miller           John_Butler          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Butler          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Doodokyan     has not voted yet
#   Message From:    Kim_Miller           John_Doodokyan       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Doodokyan       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Jeffs         has not voted yet
#   Message From:    Kim_Miller           John_Jeffs           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Jeffs           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Lasersohn     has not voted yet
#   Message From:    Kim_Miller           John_Lasersohn       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Lasersohn       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Mansperger    has not voted yet
#   Message From:    Kim_Miller           John_Mansperger      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Mansperger      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Nadler        has not voted yet
#   Message From:    Kim_Miller           John_Nadler          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Nadler          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Oberstar      has not voted yet
#   Message From:    Kim_Miller           John_Oberstar        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Oberstar        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# John_Piggott       has not voted yet
#   Message From:    Kim_Miller           John_Piggott         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           John_Piggott         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Joseph_Kuo         has not voted yet
#   Message From:    Kim_Miller           Joseph_Kuo           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Joseph_Kuo           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Juergen_Weltz      has not voted yet
#   Message From:    Kim_Miller           Juergen_Weltz        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Juergen_Weltz        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Keerti_Narayan     has not voted yet
#   Message From:    Kim_Miller           Keerti_Narayan       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Keerti_Narayan       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Keith_Britany      has not voted yet
#   Message From:    Kim_Miller           Keith_Britany        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Keith_Britany        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ken_Cahill         has not voted yet
#   Message From:    Kim_Miller           Ken_Cahill           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ken_Cahill           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ken_Krantz         has not voted yet
#   Message From:    Kim_Miller           Ken_Krantz           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ken_Krantz           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# KM_Admin           has not voted yet
#   Message From:    Kim_Miller           KM_Admin             What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           KM_Admin             whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Krishna_Yetchina   has not voted yet
#   Message From:    Kim_Miller           Krishna_Yetchina     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Krishna_Yetchina     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Lars_Rider         has not voted yet
#   Message From:    Kim_Miller           Lars_Rider           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Lars_Rider           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Laurence_Kuhn      has not voted yet
#   Message From:    Kim_Miller           Laurence_Kuhn        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Laurence_Kuhn        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Lee_Wheeler        has not voted yet
#   Message From:    Kim_Miller           Lee_Wheeler          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Lee_Wheeler          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Madon_Snell        has not voted yet
#   Message From:    Kim_Miller           Madon_Snell          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Madon_Snell          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Marco_Milletti     has not voted yet
#   Message From:    Kim_Miller           Marco_Milletti       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Marco_Milletti       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mark_Habberley     has not voted yet
#   Message From:    Kim_Miller           Mark_Habberley       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mark_Habberley       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mark_Reinheimer    has not voted yet
#   Message From:    Kim_Miller           Mark_Reinheimer      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mark_Reinheimer      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mark_Thorpe        has not voted yet
#   Message From:    Kim_Miller           Mark_Thorpe          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mark_Thorpe          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Marton_Toth        has not voted yet
#   Message From:    Kim_Miller           Marton_Toth          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Marton_Toth          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Marty_Fauth        has not voted yet
#   Message From:    Kim_Miller           Marty_Fauth          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Marty_Fauth          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Matthew_Lewsadder  has not voted yet
#   Message From:    Kim_Miller           Matthew_Lewsadder    What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Matthew_Lewsadder    whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Matt_Hill          has not voted yet
#   Message From:    Kim_Miller           Matt_Hill            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Matt_Hill            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Michael_Kahn       has not voted yet
#   Message From:    Kim_Miller           Michael_Kahn         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Michael_Kahn         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Michael_Orr        has not voted yet
#   Message From:    Kim_Miller           Michael_Orr          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Michael_Orr          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Michael_Skowronek  has not voted yet
#   Message From:    Kim_Miller           Michael_Skowronek    What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Michael_Skowronek    whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Michael_Wilson     has not voted yet
#   Message From:    Kim_Miller           Michael_Wilson       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Michael_Wilson       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mike_Drilling      has not voted yet
#   Message From:    Kim_Miller           Mike_Drilling        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mike_Drilling        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mike_Druke         has not voted yet
#   Message From:    Kim_Miller           Mike_Druke           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mike_Druke           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mike_Ehlers        has not voted yet
#   Message From:    Kim_Miller           Mike_Ehlers          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mike_Ehlers          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mike_Weston        has not voted yet
#   Message From:    Kim_Miller           Mike_Weston          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mike_Weston          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mike_Wilkins       has not voted yet
#   Message From:    Kim_Miller           Mike_Wilkins         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mike_Wilkins         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mikhail_Zhidko     has not voted yet
#   Message From:    Kim_Miller           Mikhail_Zhidko       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mikhail_Zhidko       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Miles_Bradley      has not voted yet
#   Message From:    Kim_Miller           Miles_Bradley        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Miles_Bradley        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Mitch_Slomiak      has not voted yet
#   Message From:    Kim_Miller           Mitch_Slomiak        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Mitch_Slomiak        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Noah_Salzman       has not voted yet
#   Message From:    Kim_Miller           Noah_Salzman         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Noah_Salzman         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Patrick_Morin      has not voted yet
#   Message From:    Kim_Miller           Patrick_Morin        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Patrick_Morin        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Paul_Tyner         has not voted yet
#   Message From:    Kim_Miller           Paul_Tyner           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Paul_Tyner           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Pete_Rabbitt       has not voted yet
#   Message From:    Kim_Miller           Pete_Rabbitt         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Pete_Rabbitt         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Peter_Johnson      has not voted yet
#   Message From:    Kim_Miller           Peter_Johnson        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Peter_Johnson        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Peter_Montana      has not voted yet
#   Message From:    Kim_Miller           Peter_Montana        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Peter_Montana        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Randy_Horton       has not voted yet
#   Message From:    Kim_Miller           Randy_Horton         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Randy_Horton         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ravi_Narra         has not voted yet
#   Message From:    Kim_Miller           Ravi_Narra           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ravi_Narra           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Raymond_Miller     has not voted yet
#   Message From:    Kim_Miller           Raymond_Miller       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Raymond_Miller       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Rich_Worthington   has not voted yet
#   Message From:    Kim_Miller           Rich_Worthington     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Rich_Worthington     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Rick_Kananen       has not voted yet
#   Message From:    Kim_Miller           Rick_Kananen         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Rick_Kananen         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Robbie_Bow         has not voted yet
#   Message From:    Kim_Miller           Robbie_Bow           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Robbie_Bow           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Roger_Chapman      has not voted yet
#   Message From:    Kim_Miller           Roger_Chapman        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Roger_Chapman        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ron_McDowell       has not voted yet
#   Message From:    Kim_Miller           Ron_McDowell         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ron_McDowell         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ron_Tugender       has not voted yet
#   Message From:    Kim_Miller           Ron_Tugender         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ron_Tugender         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Russ_Towne         has not voted yet
#   Message From:    Kim_Miller           Russ_Towne           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Russ_Towne           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Ryan_Hyer          has not voted yet
#   Message From:    Kim_Miller           Ryan_Hyer            What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Ryan_Hyer            whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Samyeer_Metrani    has not voted yet
#   Message From:    Kim_Miller           Samyeer_Metrani      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Samyeer_Metrani      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Sanjeev_Balarajan  has not voted yet
#   Message From:    Kim_Miller           Sanjeev_Balarajan    What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Sanjeev_Balarajan    whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Sanjeev_Sanghera   has not voted yet
#   Message From:    Kim_Miller           Sanjeev_Sanghera     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Sanjeev_Sanghera     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Save_Torquato      has not voted yet
#   Message From:    Kim_Miller           Save_Torquato        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Save_Torquato        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Scott_StGermain    has not voted yet
#   Message From:    Kim_Miller           Scott_StGermain      What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Scott_StGermain      whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Shane_Reed         has not voted yet
#   Message From:    Kim_Miller           Shane_Reed           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Shane_Reed           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# S_James_Biggs      has not voted yet
#   Message From:    Kim_Miller           S_James_Biggs        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           S_James_Biggs        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Sridhar_Ramanathan has not voted yet
#   Message From:    Kim_Miller           Sridhar_Ramanathan   What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Sridhar_Ramanathan   whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Stefan_Schmitz     has not voted yet
#   Message From:    Kim_Miller           Stefan_Schmitz       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Stefan_Schmitz       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Steve_Cross        has not voted yet
#   Message From:    Kim_Miller           Steve_Cross          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Steve_Cross          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Steve_Fitzsimons   has not voted yet
#   Message From:    Kim_Miller           Steve_Fitzsimons     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Steve_Fitzsimons     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Suhas_Chelian      has not voted yet
#   Message From:    Kim_Miller           Suhas_Chelian        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Suhas_Chelian        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Tesh_Tesfaye       has not voted yet
#   Message From:    Kim_Miller           Tesh_Tesfaye         What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Tesh_Tesfaye         whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Tim_Tannatt        has not voted yet
#   Message From:    Kim_Miller           Tim_Tannatt          What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Tim_Tannatt          whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Tom_Feasby         has not voted yet
#   Message From:    Kim_Miller           Tom_Feasby           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Tom_Feasby           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Tony_Christopher   has not voted yet
#   Message From:    Kim_Miller           Tony_Christopher     What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Tony_Christopher     whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Tony_Pogue         has not voted yet
#   Message From:    Kim_Miller           Tony_Pogue           What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Tony_Pogue           whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# Vern_Mcgeorge      has not voted yet
#   Message From:    Kim_Miller           Vern_Mcgeorge        What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           Vern_Mcgeorge        whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
# William_Burton     has not voted yet
#   Message From:    Kim_Miller           William_Burton       What's Your Score? Please Take Your User Quiz and Find Out! We want to better und     Pending
#   Message From:    Kim_Miller           William_Burton       whats-your-score-please-take-your-user-quiz-and-find-out We want to better und     Sent
#
#
#
# Discourse Men
# Processed Users                     168
# Skipped Users                       0
# Messages Sent                       0
#
#
# User Scores
# New Vote Targets                    0
# New User Scores                     0
# Updated User Scores                 0
# New User Badges                     0
# Not Voted Targets                   161
# Messages Sent                       161
#
# Process finished with exit code 0


