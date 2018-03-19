;+
; This routine plots quantities calculated by analyze_moments.pro
; (e.g., collision frequencies and temperatures).
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; MOMENTS (required)
;    Struct or dictionary containing moments data, such as returned by
;    analyze_moments.pro.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; PARAMS (default: none)
;    Parameter dictionary, such as returned by set_eppic_params.pro.
;    This routine uses nout and dt from params to construct the time
;    vector for plots. If the user does not supply params, this
;    routine will simply use a vector of time indices.
; RAW_MOMENTS (default: unset)
;    Boolean keyword to indicate whether or not to plot raw moments.
;-
pro plot_moments, moments, $
                  lun=lun, $
                  params=params, $
                  path=path, $
                  raw_moments=raw_moments

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1

  ;;==Convert moments struct to dictionary
  if isa(moments,'struct') then m_dict = dictionary(moments,/extract)

  ;;==Get number of distributions
  m_keys = m_dict.keys()
  dist_keys = m_keys[where(strmatch(m_dict.keys(),'dist*',/fold_case),n_dist)]
  dist_keys = strlowcase(dist_keys)

  ;;==Get number of time steps
  nt = n_elements(reform(moments.dist1.nu))
  tvec = dindgen(nt)
  xtitle = 'Time Index'
  if n_elements(params) ne 0 then begin
     tvec *= params.nout*params.dt*1e3
     xtitle = 'Time [ms]'
  endif

  ;;==Declare which quantities to plot
  variables = hash()
  if keyword_set(raw_moments) then begin
     variables['Raw 1st moment [$m/s$]'] = $
        dictionary('data', ['vx_m1','vy_m1','vz_m1'], $
                   'name', ['$<V_x>$','$<V_y>$','$<V_z>$'], $
                   'format', ['b-','r-','g-'])
     variables['Raw 2nd moment [$m^2/s^2$]'] = $
        dictionary('data', ['vx_m2','vy_m2','vz_m2'], $
                   'name', ['$<V_x^2>$','$<V_y^2>$','$<V_z^2>$'], $
                   'format', ['b-','r-','g-'])
     variables['Raw 3rd moment [$m^3/s^3$]'] = $
        dictionary('data', ['vx_m3','vy_m3','vz_m3'], $
                   'name', ['$<V_x^3>$','$<V_y^3>$','$<V_z^3>$'], $
                   'format', ['b-','r-','g-'])
     variables['Raw 4th moment [$m^4/s^4$]'] = $
        dictionary('data', ['vx_m4','vy_m4','vz_m4'], $
                   'name', ['$<V_x^4>$','$<V_y^4>$','$<V_z^4>$'], $
                   'format', ['b-','r-','g-'])
  endif $
  else begin
     variables['Collision frequency [$s^{-1}$]'] = $
        dictionary('data', ['nu','nu_start'], $
                   'name', ['$\nu_{sim}$','$\nu_{inp}$'], $
                   'format', ['b-','b--'])
     variables['Component temperature [$K$]'] = $
        dictionary('data', ['Tx','Ty','Tz', $
                            'Tx_start','Ty_start','Tz_start'], $
                   'name', ['$T_{x,sim}$','$T_{y,sim}$','$T_{z,sim}$', $
                            '$T_{x,inp}$','$T_{y,inp}$','$T_{z,inp}$'], $
                   'format', ['b-','r-','g-','b--','r--','g--'])
     variables['Total temperature [$K$]'] = $
        dictionary('data', ['T','T_start'], $
                   'name', ['$T_{sim}$','$T_{inp}$'], $
                   'format', ['b-','b--'])
     variables['Pedersen drift speed [$m/s$]'] = $
        dictionary('data', ['v_ped','v_ped_start'], $
                   'name', ['$V_{P,sim}$','$V_{P,inp}$'], $
                   'format', ['b-','b--'])
     variables['Hall drift speed [$m/s$]'] = $
        dictionary('data', ['v_hall','v_hall_start'], $
                   'name', ['$V_{H,sim}$','$V_{H,inp}$'], $
                   'format', ['b-','b--'])
     variables['Mean Velocity [$m/s$]'] = $
        dictionary('data', ['vx_m1','vy_m1','vz_m1'], $
                   'name', ['$<V_x>$','$<V_y>$','$<V_z>$'], $
                   'format', ['b-','r-','g-'])
  endelse
  n_pages = variables.count()
  v_keys = variables.keys()
  
  ;;==Loop over distributions
  for id=0,n_dist-1 do begin
     
     ;;==Extract the currect distribution
     idist = (m_dict[dist_keys[id]])[*]

     ;;==Set up array of plot handles
     plt = objarr(n_pages)

     ;;==Loop over quantities
     for ip=0,n_pages-1 do begin

        ;;==Get the current variables list
        ivar = variables[v_keys[ip]]
        n_var = n_elements(ivar.data)

        if n_var ne 0 then begin

           ;;==Calculate the global min and max values
           idata = reform(idist[ivar.data[0]])
           ymin = min(idata[nt/4:*])
           ymax = max(idata[nt/4:*])
           for iv=1,n_var-1 do begin
              idata = reform(idist[ivar.data[iv]])
              if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
              ymin = min([ymin,min(idata[nt/4:*])])
              ymax = max([ymax,max(idata[nt/4:*])])
           endfor
           pad = (ymin lt 0) ? 1.1 : 0.9
           ymin *= pad
           pad = (ymax gt 0) ? 1.1 : 0.9
           ymax *= pad

           ;;==Create distribution-specific plots
           idata = reform(idist[ivar.data[0]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           plt[ip] = plot(tvec,idata, $
                          ivar.format[0], $
                          /buffer, $
                          yrange = [ymin,ymax], $
                          xstyle = 1, $
                          ystyle = 1, $
                          xtitle = xtitle, $
                          ytitle = v_keys[ip], $
                          name = ivar.name[0])
           if n_var gt 1 then opl = objarr(n_var-1)
           for iv=1,n_var-1 do begin
              idata = reform(idist[ivar.data[iv]])
              if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
              opl[iv-1] = plot(tvec,idata, $
                               ivar.format[iv], $
                               /overplot, $
                               name = ivar.name[iv])
           endfor
           leg = legend(target = [plt[ip],opl], $
                        /auto_text_color)
           opl = !NULL
           leg = !NULL
        endif
     endfor

     ;;==Save
     if keyword_set(raw_moments) then $
        filename = path+path_sep()+dist_keys[id]+'_raw_moments.pdf' $
     else $
        filename = path+path_sep()+dist_keys[id]+'_moments.pdf'

     image_save, plt,filename=filename,lun=lun
     plt = !NULL

  endfor

  ;;==Create common-quantity plots
  variables = hash()
  variables['Psi factor'] = dictionary('data', ['Psi','Psi_start'], $
                                       'name', ['$\Psi_{0,sim}$', $
                                                '$\Psi_{0,inp}$'], $
                                       'format', ['b-','b--'])
  variables['Sound speed'] = dictionary('data', ['Cs','Cs_start'], $
                                        'name', ['$C_{s,sim}$', $
                                                 '$C_{s,inp}$'], $
                                        'format', ['b-','b--'])
  n_pages = variables.count()
  v_keys = variables.keys()

  ;;==Set up array of plot handles
  plt = objarr(n_pages)

  ;;==Loop over quantities
  for ip=0,n_pages-1 do begin

     ;;==Get the current variables list
     ivar = variables[v_keys[ip]]
     n_var = n_elements(ivar.data)

     if n_var ne 0 then begin

        ;;==Calculate the global min and max values
        idata = reform(m_dict[ivar.data[0]])
        ymin = min(idata[nt/4:*])
        ymax = max(idata[nt/4:*])
        for iv=1,n_var-1 do begin
           idata = reform(m_dict[ivar.data[iv]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           ymin = min([ymin,min(idata[nt/4:*])])
           ymax = max([ymax,max(idata[nt/4:*])])
        endfor
        pad = (ymin lt 0) ? 1.1 : 0.9
        ymin *= pad
        pad = (ymax gt 0) ? 1.1 : 0.9
        ymax *= pad

        ;;==Create distribution-specific plots
        idata = reform(m_dict[ivar.data[0]])
        if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
        plt[ip] = plot(tvec,idata, $
                       ivar.format[0], $
                       /buffer, $
                       yrange = [ymin,ymax], $
                       xstyle = 1, $
                       ystyle = 1, $
                       xtitle = xtitle, $
                       ytitle = v_keys[ip], $
                       name = ivar.name[0])
        if n_var gt 1 then opl = objarr(n_var-1)
        for iv=1,n_var-1 do begin
           idata = reform(m_dict[ivar.data[iv]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           opl[iv-1] = plot(tvec,idata, $
                            ivar.format[iv], $
                            /overplot, $
                            name = ivar.name[iv])
        endfor
        leg = legend(target = [plt[ip],opl], $
                     /auto_text_color)
        opl = !NULL
        leg = !NULL
     endif
  endfor

  ;;==Save
  image_save, plt,filename=path+path_sep()+'common_moments.pdf',lun=lun
  plt = !NULL

end
