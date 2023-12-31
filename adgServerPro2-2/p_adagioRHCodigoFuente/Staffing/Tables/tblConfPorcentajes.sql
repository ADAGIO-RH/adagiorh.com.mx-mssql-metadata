USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblConfPorcentajes](
	[IDConfiguracion] [int] IDENTITY(1,1) NOT NULL,
	[IDSucursal] [int] NULL,
	[IDPuesto] [int] NULL,
	[Porcentaje] [int] NULL,
 CONSTRAINT [Pk_StaffingtblConfPorcentajes_IDConfiguracion] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblConfPorcentajes]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblConfPorcentajes_RHtblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Staffing].[tblConfPorcentajes] CHECK CONSTRAINT [FK_StaffingtblConfPorcentajes_RHtblCatPuestos_IDPuesto]
GO
ALTER TABLE [Staffing].[tblConfPorcentajes]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblConfPorcentajes_RHtblCatSucursales_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Staffing].[tblConfPorcentajes] CHECK CONSTRAINT [FK_StaffingtblConfPorcentajes_RHtblCatSucursales_IDSucursal]
GO
