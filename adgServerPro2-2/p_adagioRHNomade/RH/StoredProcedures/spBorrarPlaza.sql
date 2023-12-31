USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Incidencias empleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2022-01-26
** Paremetros		: 
	 

** Notas: Temp table @tempResponse - TipoRespuesta  
  -1 - Sin respuesta  
   0 - Eliminado  
   1 - EsperaDeConfirmación  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [RH].[spBorrarPlaza] --48,1,1
(
	@IDPlaza int,
	@ConfirmadoEliminar bit = 0 ,
	@IDUsuario int
) as

	SET ANSI_WARNINGS OFF
	declare 
		--@IDPlaza int = 1,
		--@ConfirmadoEliminar bit = 0 ,
		--@IDUsuario int = 1,
		@TotalDePosiciones int = 0,
		@mensajeConfirmar varchar(max) = '',
		@mensajePlazasEliminadas varchar(100) = '',
		@OldJSON varchar(max),
		@NewJSON varchar(max),
		@HTMLListOut varchar(max)
	;

	--select @TotalDePosiciones = count(*)
	--from [RH].[tblCatPosiciones]
	--where IDPlaza = @IDPlaza

  
    declare @tempResponse as table(  
		ID int  
		,Mensaje Nvarchar(max)  
		,TipoRespuesta int  
    );  

	declare @tempTotalPlazasPosiciones as table(
		IDPlaza int,
		Codigo	App.SMName,
		Nombre	App.MDName,
		TotalPosiciones int,
		IDPuesto int
	)

	;With CteChildsPlazas   
	As    
	(            
		select p.IDPlaza , p.Codigo, JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion, p.ParentId, p.IDPuesto
		from RH.tblCatPlazas p with (nolock)  
			inner join RH.tblCatPuestos puestos on puestos.IDPuesto = p.IDPuesto
		where p.IDPlaza = @IDPlaza     
		union All    
		select p.IDPlaza , p.Codigo,JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion  , p.ParentId , p.IDPuesto
		from RH.tblCatPlazas p with (nolock)  
		inner join RH.tblCatPuestos puestos
				on puestos.IDPuesto = p.IDPuesto
			Inner Join CteChildsPlazas pc On pc.IDPlaza  = p.ParentId
	)  
	insert @tempTotalPlazasPosiciones
	select *
	from (
		select  p.IDPlaza,p.Codigo, p.Descripcion as Nombre, COUNT(po.IDPosicion) as TotalPosiciones , P.IDPuesto
		from CteChildsPlazas p 
			left join [RH].[tblCatPosiciones] po on po.IDPlaza = p.IDPlaza
			inner join RH.tblCatPuestos puestos
				on puestos.IDPuesto = p.IDPuesto
		group by p.IDPlaza,p.Codigo, p.Descripcion, p.IDPuesto
	) d
	order by TotalPosiciones desc, d.Nombre
	OPTION (MAXRECURSION 1000);  

	select @TotalDePosiciones=SUM(TotalPosiciones) from @tempTotalPlazasPosiciones
	set @mensajePlazasEliminadas = case when @TotalDePosiciones > 0 then FORMATMESSAGE('También se eliminaron %d posiciones asociadas a la plaza', @TotalDePosiciones) else '' end;

	set @HTMLListOut  = '<ul class=''ul-listaplazas-borrar''>'

	select @HTMLListOut = @HTMLListOut + 
		FORMATMESSAGE('<li>%s - %s</li>', 
			ep.Nombre,
			case 
				when ep.TotalPosiciones = 0 then '[Sin posiciones]'
				when ep.TotalPosiciones = 1 then '1 posición'
				when ep.TotalPosiciones > 1 then FORMATMESSAGE('%d posiciones', ep.TotalPosiciones) else '' end			
		)
	FROM @tempTotalPlazasPosiciones ep

	set @HTMLListOut = @HTMLListOut+'</ul>'

	if (
		(exists (select top 1 1
			from [RH].[tblCatPlazas]
			where ParentId = @IDPlaza) 
		or 
		exists (select top 1 1
			from [RH].[tblCatPosiciones]
			where IDPlaza = @IDPlaza)
		)
		and @ConfirmadoEliminar = 0
	)
	BEGIN
		set @mensajeConfirmar = FORMATMESSAGE('<label>Las siguientes plazas y sus posicione serán eliminadas</label> <br /> <br /> %s', @HTMLListOut)
		select @IDPlaza as ID
			,@mensajeConfirmar as Mensaje
			,1 as TipoRespuesta
		return; 
	END
	 
	delete Reclutamiento.tblNotasEntrevistaCandidatoPLaza 
	where IDCandidatoPlaza in (select IDCandidatoPlaza 
								from Reclutamiento.tblCandidatoPlaza 
								where IDPlaza in (select IDPlaza 
												from @tempTotalPlazasPosiciones)
											)

	delete Reclutamiento.TblResultadosCandidatoPlaza
		where IDCandidatoPlaza in (select IDCandidatoPlaza 
								from Reclutamiento.tblCandidatoPlaza 
								where IDPlaza in (select IDPlaza 
												from @tempTotalPlazasPosiciones)
											)

	delete Reclutamiento.tblCandidatoPlaza where IDPlaza in (select IDPlaza from @tempTotalPlazasPosiciones)
	delete RH.tblCatPlazas where IDPlaza in (select IDPlaza from @tempTotalPlazasPosiciones)

	select @OldJSON = a.JSON from RH.tblCatPlazas b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDPlaza = @IDPlaza
		
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPlazas]','[RH].[spBorrarPlaza]','DELETE','',@OldJSON

	select @IDPlaza as ID
		,FORMATMESSAGE('La plaza fue elimianda correctamente. %s', @mensajePlazasEliminadas) as Mensaje
		,0 as TipoRespuesta
GO
