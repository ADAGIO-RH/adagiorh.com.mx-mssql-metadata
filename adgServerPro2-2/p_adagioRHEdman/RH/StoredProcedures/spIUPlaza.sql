USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUPlaza](
	@IDPlaza int = 0,
	@IDCliente int,
	@Codigo [App].[SMName] = null,
	@IDPuesto int,
	@ParentId int,
	@Nivel int,
	@IDUsuario int,
    @ConfiguracionesJson varchar(max),	
    @ReiniciarUnidad bit
) as
	
	declare 
		@MAXClaveID  int = 0,
		@Longitud int = 4,  
		@Prefijo varchar(10),
		@EjecutarRutas bit
	;

	select @EjecutarRutas = cast( valor as bit) 
	from app.tblConfiguracionesGenerales with(nolock)
	where IDConfiguracion = 'EjecutarRutas'

	select @Prefijo = Prefijo    
	from RH.tblCatClientes  with(nolock)  
	where IDCliente = @IDCliente 
	
	select @MAXClaveID = isnull(MAX(cast(REPLACE(p.Codigo, isnull(C.Prefijo,''),'') as int)),0)  
	from RH.tblCatPlazas p  with(nolock)   
		Inner join RH.tblCatClientes C   with(nolock)
			on p.IDCliente = C.IDCliente  
	where p.IDCliente = @IDCliente

	set @MAXClaveID = isnull(@MAXClaveID,0) + 1  

	select @Codigo = 
			isnull(@Prefijo,'')+
			REPLICATE('0',@Longitud - LEN(RTRIM(cast( @MAXClaveID as varchar)))) + 
			cast( @MAXClaveID as Varchar)  

	if (ISNULL(@IDPlaza, 0) = 0)
	begin
		insert [RH].[tblCatPlazas](IDCliente, Codigo, IDPuesto, ParentId,Configuraciones,TotalPosiciones,PosicionesOcupadas,PosicionesDisponibles, IDNivelSalarial)
		values(@IDCliente, @Codigo, @IDPuesto, @ParentId,@ConfiguracionesJson,0,0,0, @Nivel)
  
		set @IDPlaza = @@IDENTITY

        INSERT RH.tblEstatusPlazas(IDPlaza,IDEstatus,IDUsuario)
	    values(@IDPlaza, CASE WHEN @EjecutarRutas = 1 THEN 1 ELSE 2 END , @IDUsuario)
	end else
	begin
		update [RH].[tblCatPlazas]
			set
				Codigo = @Codigo,
				IDPuesto = @IDPuesto,
				ParentId = @ParentId,
                Configuraciones=@ConfiguracionesJson,
				IDNivelSalarial = @Nivel
		where IDPlaza = @IDPlaza

        --select * From rh.tblEstatusPlazas
        DECLARE @IDEstatusPlaza int,
                @IDUnidad int
		
		select  top 1 
		 	@IDEstatusPlaza=estatusPlaza.IDEstatus 
	    from rh.tblCatPlazas plazas
		    left join RH.tblEstatusPlazas estatusPlaza on estatusPlaza.IDPlaza = plazas.IDPlaza 
		    left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPlaza.IDEstatus and estatus.IDTipoCatalogo = 4
        where  plazas.IDPlaza=@IDPlaza
        ORDER by plazas.IDPlaza, estatusPlaza.FechaReg  desc
		 
        IF(@IDEstatusPlaza=5)
        begin 
            insert into rh.tblEstatusPlazas (IDPlaza,IDEstatus,IDUsuario) values (@IDPlaza,1,@IDUsuario)

            if(@ReiniciarUnidad  = 1 )
            BEGIN
                select @IDUnidad=U.IDUnidad From Enrutamiento.tblUnidadProceso U
                where IDCatTipoProceso=1 and IDReferencia=@IDPlaza            
                exec [Enrutamiento].[spReiniciarUnidadProceso] @IDUnidad=@IDUnidad, @IDUsuario=@IDUsuario
            end
        end
	end

    /*
	MERGE [RH].[tblConfiguracionesPlazas] AS TARGET
	USING @dtConfiguracionPlaza as SOURCE
	on TARGET.IDConfiguracionPlaza = SOURCE.IDConfiguracionPlaza
	WHEN MATCHED THEN
		update 
			set TARGET.Valor = SOURCE.Valor
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDPlaza,IDTipoConfiguracionPlaza, Valor)
		values(@IDPlaza, SOURCE.IDTipoConfiguracionPlaza,SOURCE.Valor)
	;*/

	exec [RH].[spActualizarTotalesPosiciones] @IDPlaza = @IDPlaza, @IDUsuario = @IDUsuario	
	exec [RH].[spBuscarPlazas] @IDPlaza = @IDPlaza, @IDUsuario = @IDUsuario
GO
