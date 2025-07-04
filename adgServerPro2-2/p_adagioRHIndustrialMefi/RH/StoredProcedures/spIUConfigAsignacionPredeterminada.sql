USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spIUConfigAsignacionPredeterminada](
	 @IDConfigAsignacionPredeterminada int	= 0	
	,@IDDepartamento int				= NULL	
	,@IDSucursal int					= NULL
	,@IDPuesto int						= NULL
	,@IDClasificacionCorporativa int	= NULL	
	,@IDDivision int					= NULL
	,@IDTipoNomina int					= NULL
	,@IDsJefe nvarchar(max)				= NULL
	,@IDsLectores nvarchar(max)			= NULL
	,@IDsSupervisores nvarchar(max)		= NULL
    ,@IDTipoPrestacion int              = NULL
    ,@IDArea int                        = NULL
    ,@IDRazonSocial int                 = NULL
    ,@IDRegion int                      = NULL
    ,@IDCliente int                     = NULL
    ,@IDRegPatronal int                 = NULL
    ,@IDCentroCostos int                 = NULL
	,@IDUsuario int					
)AS
	declare @Factor int = 0;

	declare  @tblTempFactor as table(
		f int
	);


	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select   @IDDepartamento				= case when @IDDepartamento				 = 0 then null else @IDDepartamento				   end
			,@IDSucursal					= case when @IDSucursal					 = 0 then null else @IDSucursal					   end
			,@IDPuesto						= case when @IDPuesto					 = 0 then null else @IDPuesto					   end
			,@IDClasificacionCorporativa	= case when @IDClasificacionCorporativa	 = 0 then null else @IDClasificacionCorporativa	   end
			,@IDDivision					= case when @IDDivision					 = 0 then null else @IDDivision					   end
			,@IDArea					    = case when @IDArea				         = 0 then null else @IDArea				           end
			,@IDRazonSocial					= case when @IDRazonSocial				 = 0 then null else @IDRazonSocial				   end
			,@IDRegion					    = case when @IDRegion				     = 0 then null else @IDRegion				       end
			,@IDTipoNomina					= case when @IDTipoNomina				 = 0 then null else @IDTipoNomina				   end
			,@IDTipoPrestacion				= case when @IDTipoPrestacion			 = 0 then null else @IDTipoPrestacion			   end
			,@IDCliente				        = case when @IDCliente			         = 0 then null else @IDCliente			           end
			,@IDRegPatronal				    = case when @IDRegPatronal			     = 0 then null else @IDRegPatronal			       end
			,@IDCentroCostos				= case when @IDCentroCostos			     = 0 then null else @IDCentroCostos			       end



	insert @tblTempFactor(f)
	values(case when isnull(@IDDepartamento,0) != 0 then 3 else 0 end)
	 	 ,(case when isnull(@IDSucursal,0) != 0 then 5 else 0 end)
	 	 ,(case when isnull(@IDPuesto,0) != 0 then 4 else 0 end)
	 	 ,(case when isnull(@IDClasificacionCorporativa,0) != 0 then 2 else 0 end)
	 	 ,(case when isnull(@IDDivision,0) != 0 then 1 else 0 end)
	 	 ,(case when isnull(@IDTipoNomina,0) != 0 then 6 else 0 end)

	select @Factor = sum(f) from @tblTempFactor
	if (@IDConfigAsignacionPredeterminada = 0)
	begin 
		insert [RH].[tblConfigAsignacionesPredeterminadas](IDDepartamento,IDSucursal,IDPuesto,IDClasificacionCorporativa,IDDivision,
		IDTipoNomina,IDsJefe,IDsLectores,IDsSupervisores,Factor,IDUsuario
		,IDCliente,IDAreas,IDCentroCostos,IDRazonSocial,IDRegiones,IDRegPatronal,IDTipoPrestaciones)
		values (@IDDepartamento,@IDSucursal,@IDPuesto,@IDClasificacionCorporativa,@IDDivision,
		@IDTipoNomina,@IDsJefe,@IDsLectores,@IDsSupervisores,@Factor,@IDUsuario
		,@IDCliente,@IDArea,@IDCentroCostos,@IDRazonSocial,@IDRegion,@IDRegPatronal,@IDTipoPrestacion)

		select @IDConfigAsignacionPredeterminada = @@IDENTITY

		
		select @NewJSON = a.JSON from [RH].[tblConfigAsignacionesPredeterminadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfigAsignacionesPredeterminadas]','[RH].[spIUConfigAsignacionPredeterminada]','INSERT',@NewJSON,''

	end else
	begin

		select @OldJSON = a.JSON from [RH].[tblConfigAsignacionesPredeterminadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada

		update [RH].[tblConfigAsignacionesPredeterminadas]
			set  IDDepartamento				 = @IDDepartamento
				,IDSucursal					 = @IDSucursal
				,IDPuesto					 = @IDPuesto
				,IDClasificacionCorporativa	 = @IDClasificacionCorporativa
				,IDDivision					 = @IDDivision
				,IDTipoNomina				 = @IDTipoNomina
				,IDsJefe					 = @IDsJefe
				,IDsLectores				 = @IDsLectores
				,IDsSupervisores			 = @IDsSupervisores
				,Factor						 = @Factor
				,IDCliente					 = @IDCliente
				,IDAreas					 = @IDArea
				,IDCentroCostos				 = @IDCentroCostos
				,IDRazonSocial				 = @IDRazonSocial
				,IDRegiones					 = @IDRegion
				,IDRegPatronal				 = @IDRegPatronal
				,IDTipoPrestaciones			 = @IDTipoPrestacion
				--,IDUsuario					 = @IDUsuario
		where IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada

		select @NewJSON = a.JSON from [RH].[tblConfigAsignacionesPredeterminadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfigAsignacionesPredeterminadas]','[RH].[spIUConfigAsignacionPredeterminada]','UPDATE',@NewJSON,@OldJSON
	end;
GO
