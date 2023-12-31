USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spAsignarColaboradorAPosicionByCandidatoPlaza] --11,4405,1
(
	@IDCandidatoPlaza int,
	@IDEmpleado int,
	@IDUsuario int
) as
	declare 
		@IDPlaza int
		,@IDPlazaAnterior int
		,@IDPosicion int
		,@IDPosicionAnterior int
	;

	select @IDPlaza = IDPlaza
	from Reclutamiento.tblCandidatoPlaza
	where IDCandidatoPlaza = @IDCandidatoPlaza

	select top 1
		@IDPosicionAnterior = IDPosicion,
		@IDPlazaAnterior = IDPlaza
	from RH.tblCatPosiciones with(nolock)
	where IDEmpleado = @IDEmpleado
   
	if(isnull(@IDPosicionAnterior,0) > 0)
	BEGIN
		update RH.tblCatPosiciones 
			set
				IDEmpleado = null
		where IDPosicion = @IDPosicionAnterior

		-- Estatus de Ocupada
		insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
		select @IDPosicionAnterior,2,@IDUsuario,null

		EXEC [RH].[spActualizarTotalesPosiciones] @IDPlazaAnterior, @IDUsuario
	 END

	IF object_ID('TEMPDB..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones
	
	Select p.IDPlaza 
		, p.IDPosicion
		, p.IDEmpleado
	into #TempPosiciones
	from RH.tblCatPosiciones P with(nolock)
	 
	WHERE p.IDPlaza = @IDPlaza and p.IDEmpleado is null

	select top 1 @IDPosicion = p.IDPosicion 
				-- ,@IDPlaza = p.IDPlaza
	from rh.tblcatposiciones p
	where  p.IDEmpleado is null 
		and p.IDPosicion in (select IDPosicion from #TempPosiciones where IDEmpleado is null)
		and ( select  top 1 IDEstatus  
				from rh.tblestatusposiciones pp with(nolock) 
				where pp.IDPosicion=p.IDPosicion 
				order by fechaReg desc ) = 2

	update p
		set
			IDEmpleado = @IDEmpleado
	from RH.tblCatPosiciones p
	where IDPosicion = @IDPosicion
	

	-- Estatus de Ocupada
	insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	select @IDPosicion,3,@IDUsuario,@IDEmpleado

	EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza, @IDUsuario
GO
