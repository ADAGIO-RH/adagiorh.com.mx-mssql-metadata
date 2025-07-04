USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatVehiculos](
	[IDVehiculo] [int] IDENTITY(1,1) NOT NULL,
	[ClaveVehiculo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDMarcaVehiculo] [int] NOT NULL,
	[IDTipoVehiculo] [int] NOT NULL,
	[IDTipoCombustible] [int] NULL,
	[IDTipoCosto] [int] NULL,
	[CantidadPasajeros] [int] NULL,
	[NumeroEconomico] [int] NULL,
	[Status] [int] NULL,
	[CostoUnidad] [decimal](10, 2) NULL,
 CONSTRAINT [PK_TransportetblVehiculos_IDVehiculo] PRIMARY KEY CLUSTERED 
(
	[IDVehiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatVehiculos] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Transporte].[tblCatVehiculos] ADD  DEFAULT ((0.00)) FOR [CostoUnidad]
GO
ALTER TABLE [Transporte].[tblCatVehiculos]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatMarcaVehiculos_TransportetblVehiculos_IDMarcaVehiculo] FOREIGN KEY([IDMarcaVehiculo])
REFERENCES [Transporte].[tblCatMarcaVehiculos] ([IDMarcaVehiculo])
GO
ALTER TABLE [Transporte].[tblCatVehiculos] CHECK CONSTRAINT [FK_TransportetblCatMarcaVehiculos_TransportetblVehiculos_IDMarcaVehiculo]
GO
ALTER TABLE [Transporte].[tblCatVehiculos]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatTipoCombustible_TransportetblVehiculos_IDTipoCombustible] FOREIGN KEY([IDTipoCombustible])
REFERENCES [Transporte].[tblCatTipoCombustible] ([IDTipoCombustible])
GO
ALTER TABLE [Transporte].[tblCatVehiculos] CHECK CONSTRAINT [FK_TransportetblCatTipoCombustible_TransportetblVehiculos_IDTipoCombustible]
GO
ALTER TABLE [Transporte].[tblCatVehiculos]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatTipoCosto_TransportetblVehiculos_IDTipoCosto] FOREIGN KEY([IDTipoCosto])
REFERENCES [Transporte].[tblCatTipoCosto] ([IDTipoCosto])
GO
ALTER TABLE [Transporte].[tblCatVehiculos] CHECK CONSTRAINT [FK_TransportetblCatTipoCosto_TransportetblVehiculos_IDTipoCosto]
GO
ALTER TABLE [Transporte].[tblCatVehiculos]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatTipoVehiculo_TransportetblVehiculos_IDTipoVehiculo] FOREIGN KEY([IDTipoVehiculo])
REFERENCES [Transporte].[tblCatTipoVehiculo] ([IDTipoVehiculo])
GO
ALTER TABLE [Transporte].[tblCatVehiculos] CHECK CONSTRAINT [FK_TransportetblCatTipoVehiculo_TransportetblVehiculos_IDTipoVehiculo]
GO
